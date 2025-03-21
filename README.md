# AWS Training ECR/ECS demo3

This project is a simple Node.js application exposing resources via `/api/items`, using AWS DynamoDB as the database. It is used for training on Docker, AWS ECR/ECS, and Terraform for deployment.

## Prerequisites

Before getting started, make sure you have installed:

- [Docker](https://www.docker.com/get-started)
- [AWS CLI](https://aws.amazon.com/cli/)
- [Terraform](https://www.terraform.io/downloads)
- An AWS account with access to ECR, ECS, and DynamoDB

## Installation and Running

1. **Clone the repository**
   ```sh
   git clone <REPO_URL>
   cd <REPO_NAME>
   ```

2. **Build and run the container locally**
   ```sh
   docker build -t demo3 .
   ```

3. **Access the API**
   The API will be available at: [http://localhost:3000/api/items](http://localhost:3000/api/items)

4. **DynamoDB connection**
    ### Get all items
        curl http://localhost:3000/api/items

    ### Create a new item
        curl -X POST -H "Content-Type: application/json" -d '{"name":"New Item","description":"Description of new item"}' http://localhost:3000/api/items

## Deployment on AWS using Terraform

1. Initialize Terraform:

```bash
cd terraform
terraform init
```

2. Update the `terraform.tfvars` file with your desired configuration, especially the DocumentDB password.

3. Deploy the infrastructure:

```bash
terraform apply
```

4. Build and deploy the Docker image (or use the provided script):

```bash
../deploy.sh
```
## Docker Image Deployment on AWS ECR

1. **Login to AWS ECR**
   ```sh
   aws ecr get-login-password --region <REGION> | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com
   ```

2. **Create an ECR repository (if not created by Terraform)**
   ```sh
   aws ecr create-repository --repository-name demo3
   ```

3. **Build and tag the Docker image**
   ```sh
   docker build -t demo3 .
   docker tag demo3:latest <AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/demo3:latest
   ```

4. **Push the image to ECR**
   ```sh
   docker push <AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/demo3:latest
   ```

## License

This project is licensed under the MIT License.