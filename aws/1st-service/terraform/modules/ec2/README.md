# EC2 Module

## Description
Module for creating Auto Scaling Group with EC2 instances for web application.

## Requirements
- Create Launch Template with Docker and application
- Create Auto Scaling Group
- Configure scaling policies (CPU utilization)
- Create Security Group for EC2 (port 3000)
- Place instances in private subnets
- Configure IAM role for S3 and RDS access
- Create Target Group for ALB
- Attach target group to ALB listener

## Hints
- Use `aws_launch_template` to create template
- User data should install Docker and run container
- Auto Scaling Group should be in private subnets
- Security Group should allow traffic from ALB (port 3000)
- Don't forget IAM instance profile
- Target group should be of type "instance"
- Use `aws_lb_target_group_attachment` to attach instances

## Variables (variables.tf)
```hcl
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "alb_listener_arn" {
  description = "ALB listener ARN"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
```

## Outputs (outputs.tf)
```hcl
output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.main.name
}

output "asg_arn" {
  description = "Auto Scaling Group ARN"
  value       = aws_autoscaling_group.main.arn
}

output "target_group_arn" {
  description = "Target group ARN"
  value       = aws_lb_target_group.main.arn
}
```

## User Data Example
```bash
#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Pull and run application
docker pull your-ecr-repo:latest
docker run -d -p 3000:3000 \
  -e DB_HOST=${db_host} \
  -e DB_PORT=${db_port} \
  -e DB_NAME=${db_name} \
  -e DB_USER=${db_user} \
  -e DB_PASSWORD=${db_password} \
  -e S3_BUCKET=${s3_bucket} \
  your-ecr-repo:latest
``` 