# VPC 
module "vpc" {
  source      = "../modules/vpc"
  vpc_cidr    = var.vpc_cidr
  environment = var.environment
}

# S3 Bucket 
module "s3" {
  source       = "../modules/s3"
  environment  = var.environment
  project_name = var.project_name
}

# IAM Role for EC2 (used by GitHub Actions runner) 
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

# Security Group for EC2 
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg-${var.environment}"
  description = "Allow SSH and HTTP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg-${var.environment}"
  }
}

# EC2 Instance (GitHub Runner + Docker App) 
module "ec2" {
  source                   = "../modules/ec2"
  ami                      = "ami-0767046d1677be5a0" # Ubuntu 22.04 LTS
  instance_type            = "t3.micro"
  subnet_id                = module.vpc.public_subnet_ids[0]
  key_name                 = "github-runner-key"
  existing_sg_id           = aws_security_group.ec2_sg.id
  environment              = var.environment
  iam_instance_profile_name = module.iam.instance_profile_name
}
