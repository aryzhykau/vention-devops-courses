variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "aws-1st-service"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs for public subnets"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

# IAM policies declared from JSON files in infra/policies
variable "iam_policies" {
  description = "Map of IAM policies"
  type = map(object({
    description     = string
    policy_filename = string
  }))
  default = {
    s3-policy = {
      description     = "Allow S3 access for EC2"
      policy_filename = "policies/s3-policy.json"
    }
    rds-policy = {
      description     = "Allow RDS access for EC2"
      policy_filename = "policies/rds-policy.json"
    }
  }
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
  default = {
    ec2-sg = {
      description = "Allow SSH and HTTP (tighten later)"
      ingress = [
        {
          description = "SSH"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          description = "HTTP"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
    alb-sg = {
      description = "Allow HTTP to ALB"
      ingress = [
        {
          description = "HTTP"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }
}

# EC2
variable "ec2_ami" {
  description = "AMI ID"
  type        = string
  default     = "ami-0767046d1677be5a0"
}

variable "ec2_instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}

variable "ec2_key_name" {
  description = "EC2 key pair"
  type        = string
  default     = "github-runner-key"
}

# EC2 user_data template variables
variable "runner_repo_url" {
  description = "GitHub repo URL (for runner)"
  type        = string
  default     = "https://github.com/aryzhykau/vention-devops-courses"
}

variable "runner_version" {
  description = "Runner version"
  type        = string
  default     = "2.317.0"
}

variable "runner_labels" {
  description = "Runner labels (comma-separated)"
  type        = string
  default     = "ec2-runner"
}

variable "runner_token" {
  description = "Registration token (optional)"
  type        = string
  sensitive   = true
  default     = null
}

# RDS
variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}
