# VPC Module

## Description
Module for creating VPC with public and private subnets for web application.

## Requirements
- Create VPC with CIDR block (e.g., 10.0.0.0/16)
- Create 2 public subnets in different AZs (e.g., 10.0.1.0/24, 10.0.2.0/24)
- Create 2 private subnets in different AZs (e.g., 10.0.3.0/24, 10.0.4.0/24)
- Create Internet Gateway for public subnets
- Create NAT Gateway for private subnets
- Configure routing tables

## Hints
- Use `aws_vpc` resource
- For subnets use `aws_subnet` with `map_public_ip_on_launch = true` for public ones
- NAT Gateway requires Elastic IP (`aws_eip`)
- Don't forget `aws_route_table` and `aws_route_table_association`

## Variables (variables.tf)
```hcl
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment name"
  type        = string
}
```

## Outputs (outputs.tf)
```hcl
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}
``` 