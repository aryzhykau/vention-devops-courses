variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "availability_zones" {
  description = "AZs for public subnets"
  type        = list(string)
}

# IAM policies declared from JSON files in infra/policies
variable "iam_policies" {
  description = "Map of IAM policies"
  type = map(object({
    description     = string
    policy_filename = string
  }))
}

# Map of security groups 
variable "security_groups" {
  description = "Map of security groups and their rules"
  type = map(object({
    description = string
    ingress = list(object({
      description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
    egress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }))
}

# EC2
variable "ec2_ami" {
  description = "AMI ID"
  type        = string
}

variable "ec2_instance_type" {
  description = "Instance type"
  type        = string
}

variable "ec2_key_name" {
  description = "EC2 key pair"
  type        = string
}

# EC2 user_data template variables
variable "runner_repo_url" {
  description = "GitHub repo URL"
  type        = string
}

variable "runner_version" {
  description = "GitHub Actions runner version"
  type        = string
}

variable "runner_labels" {
  description = "Runner labels (comma-separated)"
  type        = string
}

variable "runner_token" {
  description = "Registration token (optional)"
  type        = string
  nullable    = true
  sensitive   = true
}

# RDS
variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

