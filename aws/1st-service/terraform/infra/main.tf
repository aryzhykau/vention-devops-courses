module "vpc" {
  source             = "../modules/vpc"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  environment        = var.environment
  project_name       = var.project_name
}

module "s3" {
  source       = "../modules/s3"
  environment  = var.environment
  project_name = var.project_name
}

module "iam" {
  source       = "../modules/iam"
  environment  = var.environment
  iam_policies = var.iam_policies
}

# Security Groups (created with for_each)
resource "aws_security_group" "sg" {
  for_each    = var.security_groups
  name        = "${each.key}-${var.environment}"
  description = each.value.description
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = each.value.egress
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "${each.key}-${var.environment}"
  }
}

module "ec2" {
  source                    = "../modules/ec2"
  ami                       = var.ec2_ami
  instance_type             = var.ec2_instance_type
  subnet_id                 = module.vpc.public_subnet_ids[0]
  key_name                  = var.ec2_key_name
  existing_sg_id            = aws_security_group.sg["ec2-sg"].id
  environment               = var.environment
  iam_instance_profile_name = module.iam.instance_profile_name
}

module "rds" {
  source                 = "../modules/rds"
  environment            = var.environment
  project_name           = var.project_name
  db_name                = "mydb"
  db_username            = "postgres"
  db_password            = var.db_password
  vpc_security_group_ids = [aws_security_group.sg["ec2-sg"].id]
  subnet_ids             = module.vpc.public_subnet_ids
}

module "alb" {
  source             = "../modules/loadbalancing"
  environment        = var.environment
  project_name       = var.project_name
  alb_sg_id          = aws_security_group.sg["alb-sg"].id
  subnet_ids         = module.vpc.public_subnet_ids
  target_instance_id = module.ec2.instance_id
  vpc_id             = module.vpc.vpc_id
}
