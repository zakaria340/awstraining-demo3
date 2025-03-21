#!/bin/bash
set -e

# Configuration
AWS_REGION="us-east-1"
PROJECT_NAME="express-app"
TERRAFORM_DIR="./terraform"

# Ensure AWS CLI is configured
if ! aws sts get-caller-identity &>/dev/null; then
  echo "Error: AWS CLI not configured. Please run 'aws configure' first."
  exit 1
fi

# Check if terraform is installed
if ! command -v terraform &>/dev/null; then
  echo "Error: Terraform is not installed. Please install Terraform first."
  exit 1
fi

# Initialize Terraform
echo "Initializing Terraform..."
cd "$TERRAFORM_DIR"
terraform init

# Apply Terraform (create infrastructure)
echo "Creating infrastructure with Terraform..."
terraform apply -var "project_name=$PROJECT_NAME" -var "aws_region=$AWS_REGION"

# Get ECR repository URL from Terraform output
ECR_REPO_URL=$(terraform output -raw repository_url)
if [ -z "$ECR_REPO_URL" ]; then
  echo "Error: Failed to get ECR repository URL from Terraform output."
  exit 1
fi

# Return to project root
cd ..

# Build the Docker image
echo "Building Docker image..."
docker build -t "$PROJECT_NAME" .

# Tag the Docker image for ECR
echo "Tagging Docker image for ECR..."
docker tag "$PROJECT_NAME:latest" "$ECR_REPO_URL:latest"

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$(echo $ECR_REPO_URL | cut -d/ -f1)"

# Push the Docker image to ECR
echo "Pushing Docker image to ECR..."
docker push "$ECR_REPO_URL:latest"

# Update the ECS service to force new deployment
echo "Updating ECS service to use the new image..."
ECS_CLUSTER_NAME=$(cd "$TERRAFORM_DIR" && terraform output -raw ecs_cluster_name)
ECS_SERVICE_NAME=$(cd "$TERRAFORM_DIR" && terraform output -raw ecs_service_name)

aws ecs update-service \
  --cluster "$ECS_CLUSTER_NAME" \
  --service "$ECS_SERVICE_NAME" \
  --force-new-deployment \
  --region "$AWS_REGION"

echo "Waiting for ECS service to stabilize..."
aws ecs wait services-stable \
  --cluster "$ECS_CLUSTER_NAME" \
  --services "$ECS_SERVICE_NAME" \
  --region "$AWS_REGION"

# Get the ALB DNS name
ALB_DNS_NAME=$(cd "$TERRAFORM_DIR" && terraform output -raw alb_hostname)

echo "===================================================="
echo "Deployment completed successfully!"
echo "Your application is accessible at: http://$ALB_DNS_NAME"
echo "===================================================="