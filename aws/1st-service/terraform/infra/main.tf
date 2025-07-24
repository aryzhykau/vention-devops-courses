# Use existing VPC
data "aws_vpc" "existing" {
  id = "vpc-0469a379c8f2f3221"
}

# Use existing Subnet
data "aws_subnet" "existing" {
  id = "subnet-03f686eb716a34167"
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
  vpc_id             = data.aws_vpc.existing.id
  environment        = var.environment
  db_password        = var.db_password
  ec2_sg_id          = module.ec2.security_group_id
}

# IAM
module "iam" {
  source      = "../modules/iam"
  environment = var.environment

  iam_policies = {
    "s3-policy" = {
      description     = "Allow S3 access for EC2"
      policy_filename = "s3-policy.json"
    },
    "rds-policy" = {
      description     = "Allow RDS access for EC2"
      policy_filename = "rds-policy.json"
    }
  }
}

# Load Balancer
module "loadbalancer" {
  source            = "../modules/loadbalancing"
  vpc_id            = data.aws_vpc.existing.id
  public_subnet_ids = [data.aws_subnet.existing.id] # single subnet
  environment       = var.environment
}

# EC2
module "ec2" {
  source          = "../modules/ec2"
  subnet_id       = data.aws_subnet.existing.id
  ami             = "ami-0767046d1677be5a0"
  instance_type   = "t2.micro"
  key_name        = "github-runner-key"
  existing_sg_id  = "sg-04a125ad25ff6bfbb"
  environment     = var.environment
}


