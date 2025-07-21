# VPC
module "vpc" {
  source      = "../modules/vpc"
  vpc_cidr    = var.vpc_cidr
  environment = var.environment
}

# S3
module "s3" {
  source       = "../modules/s3"
  environment  = var.environment
  project_name = var.project_name
}

# RDS
module "rds" {
  source             = "../modules/rds"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  environment        = var.environment
  db_password        = var.db_password
}

# IAM
module "iam" {
  source         = "../modules/iam"
  environment    = var.environment
  s3_bucket_arn  = module.s3.bucket_arn
  rds_arn        = module.rds.db_endpoint
}

# Load Balancer
module "loadbalancer" {
  source            = "../modules/loadbalancing"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  environment       = var.environment
}

# EC2 will be manually connected later
