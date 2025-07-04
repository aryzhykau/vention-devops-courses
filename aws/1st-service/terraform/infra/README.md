# Main Infrastructure

## Description
Main Terraform configuration that combines all modules.

## Requirements
- Create main.tf with calls to all modules
- Configure AWS provider
- Create variables.tf with variables
- Create outputs.tf with outputs
- Configure backend for state storage

## File Structure
```
infra/
├── main.tf          # Main configuration
├── variables.tf     # Variables
├── outputs.tf       # Outputs
├── providers.tf     # Providers
├── backend.tf       # Backend configuration
└── terraform.tfvars # Variable values (don't commit!)
```

## Hints
- Use data sources to get information about existing resources
- Pass outputs from one module as inputs to another
- Use locals for computed values
- Configure S3 backend for state storage
- Use terraform.tfvars for sensitive data

## Example main.tf
```hcl
# VPC Module
module "vpc" {
  source = "../modules/vpc"
  
  vpc_cidr    = var.vpc_cidr
  environment = var.environment
}

# S3 Module
module "s3" {
  source = "../modules/s3"
  
  environment  = var.environment
  project_name = var.project_name
}

# IAM Module
module "iam" {
  source = "../modules/iam"
  
  environment    = var.environment
  s3_bucket_arn  = module.s3.bucket_arn
  rds_arn        = module.rds.db_arn
}

# RDS Module
module "rds" {
  source = "../modules/rds"
  
  vpc_id            = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  environment       = var.environment
  db_password       = var.db_password
}

# Load Balancer Module
module "loadbalancer" {
  source = "../modules/loadbalancing"
  
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  environment       = var.environment
}

# EC2 Module
module "ec2" {
  source = "../modules/ec2"
  
  vpc_id            = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  alb_listener_arn  = module.loadbalancer.alb_listener_arn
  environment       = var.environment
  instance_type     = var.instance_type
}
```

## Backend Configuration (backend.tf)
```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "aws-1st-service/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## Provider Configuration (providers.tf)
```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}
```

## Important Points
1. **Creation Order**: VPC → S3 → IAM → RDS → Load Balancer → EC2
2. **Dependencies**: Use depends_on for explicit dependencies
3. **Security**: Don't commit terraform.tfvars with sensitive data
4. **Tagging**: Use default_tags for all resources
5. **Monitoring**: Add CloudWatch alerts and logging 