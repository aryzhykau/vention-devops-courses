# VPC
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# S3
output "bucket_name" {
  description = "S3 bucket name"
  value       = module.s3.bucket_name
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3.bucket_arn
}

# RDS
output "rds_endpoint" {
  description = "RDS Endpoint"
  value       = module.rds.db_endpoint
}

output "rds_name" {
  description = "RDS Database name"
  value       = module.rds.db_name
}

output "rds_port" {
  description = "RDS Port"
  value       = module.rds.db_port
}

# IAM
output "ec2_role_arn" {
  description = "IAM role ARN for EC2"
  value       = module.iam.ec2_role_arn
}

output "instance_profile_name" {
  description = "Instance profile name for EC2"
  value       = module.iam.instance_profile_name
}

# Load Balancer
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.loadbalancer.alb_dns_name
}

output "alb_arn" {
  description = "ALB ARN"
  value       = module.loadbalancer.alb_arn
}

output "alb_listener_arn" {
  description = "ALB listener ARN"
  value       = module.loadbalancer.alb_listener_arn
}
