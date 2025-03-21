output "repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "alb_hostname" {
  description = "The hostname of the ALB"
  value       = aws_lb.main.dns_name
}

output "documentdb_endpoint" {
  description = "The endpoint of the DocumentDB cluster"
  value       = aws_docdb_cluster.main.endpoint
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.app.name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "security_group_ecs_tasks_id" {
  description = "The ID of the ECS tasks security group"
  value       = aws_security_group.ecs_tasks.id
}

output "security_group_documentdb_id" {
  description = "The ID of the DocumentDB security group"
  value       = aws_security_group.documentdb.id
}
