// app.js
const express = require('express');
const mongoose = require('mongoose');
const app = express();
const PORT = process.env.PORT || 3000;
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://mongo:27017/expressapp';

// Connect to MongoDB
mongoose.connect(MONGODB_URI,{
  authMechanism: 'SCRAM-SHA-1',
  authSource: 'admin',
  retryWrites: false,
  directConnection: true,
  ssl: false
})
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => {
    console.error('Failed to connect to MongoDB:', err);
    process.exit(1);
  });

// Define Item schema
const itemSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Create Item model
const Item = mongoose.model('Item', itemSchema);

// Middleware for parsing JSON body
app.use(express.json());

// Root route
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to the Express API with MongoDB' });
});

// Get all items
app.get('/api/items', async (req, res) => {
  try {
    const items = await Item.find().sort({ createdAt: -1 });
    res.json(items);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Get single item
app.get('/api/items/:id', async (req, res) => {
  try {
    const item = await Item.findById(req.params.id);
    
    if (!item) {
      return res.status(404).json({ message: 'Item not found' });
    }
    
    res.json(item);
  } catch (err) {
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ message: 'Item not found' });
    }
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Create new item
app.post('/api/items', async (req, res) => {
  try {
    const { name, description } = req.body;
    
    if (!name || !description) {
      return res.status(400).json({ message: 'Name and description are required' });
    }
    
    const newItem = new Item({
      name,
      description
    });
    
    const savedItem = await newItem.save();
    res.status(201).json(savedItem);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Update item
app.put('/api/items/:id', async (req, res) => {
  try {
    const { name, description } = req.body;
    
    // Build update object
    const updateData = {};
    if (name) updateData.name = name;
    if (description) updateData.description = description;
    
    // Find and update
    const item = await Item.findByIdAndUpdate(
      req.params.id,
      { $set: updateData },
      { new: true } // Return the updated document
    );
    
    if (!item) {
      return res.status(404).json({ message: 'Item not found' });
    }
    
    res.json(item);
  } catch (err) {
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ message: 'Item not found' });
    }
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Delete item
app.delete('/api/items/:id', async (req, res) => {
  try {
    const item = await Item.findByIdAndDelete(req.params.id);
    
    if (!item) {
      return res.status(404).json({ message: 'Item not found' });
    }
    
    res.json({ message: 'Item deleted', item });
  } catch (err) {
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ message: 'Item not found' });
    }
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
