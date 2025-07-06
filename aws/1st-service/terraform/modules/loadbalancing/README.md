# Load Balancer Module

## Description
Module for creating Application Load Balancer (ALB) to distribute traffic between EC2 instances.

## Requirements
- Create Application Load Balancer
- Create listener on port 80 (HTTP)
- Configure health check for application
- Place ALB in public subnets
- Create Security Group for ALB

## Hints
- Use `aws_lb` to create ALB
- Health check path: `/api/health`
- Don't forget Security Group for ALB (port 80)
- ALB should be in public subnets
- Target group will be created in EC2 module

## Variables (variables.tf)
```hcl
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
}
```

## Outputs (outputs.tf)
```hcl
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "alb_listener_arn" {
  description = "ALB listener ARN"
  value       = aws_lb_listener.main.arn
}
``` 