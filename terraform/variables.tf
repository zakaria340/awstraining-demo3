variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project, used for naming resources"
  type        = string
  default     = "express-app"
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "express-app"
}

variable "app_port" {
  description = "Port number for the application"
  type        = number
  default     = 3000
}

variable "app_count" {
  description = "Number of instances of the application"
  type        = number
  default     = 2
}

variable "container_cpu" {
  description = "CPU units for the container"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory for the container in MB"
  type        = number
  default     = 512
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "docdb_username" {
  description = "Username for DocumentDB"
  type        = string
  default     = "adminuser"
  sensitive   = true
}

variable "docdb_password" {
  description = "Password for DocumentDB"
  type        = string
  default     = "password123456"
  sensitive   = true
}

variable "docdb_database" {
  description = "Database name for DocumentDB"
  type        = string
  default     = "expressapp"
}