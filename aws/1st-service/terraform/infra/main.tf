module "vpc" {
  source             = "../modules/vpc"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  environment        = var.environment
  project_name       = var.project_name
}

module "iam" {
  source       = "../modules/iam"
  environment  = var.environment
  iam_policies = var.iam_policies
}

module "s3" {
  source                 = "../modules/s3"
  environment            = var.environment
  project_name           = var.project_name
  allowed_principal_arns = [module.iam.ec2_role_arn]
}

# Security Groups from map
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

# Dedicated RDS SG + rule: only EC2 -> RDS:5432
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg-${var.environment}"
  description = "Allow Postgres from EC2"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg-${var.environment}"
  }
}

resource "aws_security_group_rule" "rds_ingress_from_ec2" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.sg["ec2-sg"].id
}

# Optional now: allow only ALB -> EC2 on 80
resource "aws_security_group_rule" "ec2_http_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg["ec2-sg"].id
  source_security_group_id = aws_security_group.sg["alb-sg"].id
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

  # user_data via templatefile
  runner_repo_url = var.runner_repo_url
  runner_version  = var.runner_version
  runner_labels   = var.runner_labels
  runner_token    = var.runner_token
}

module "rds" {
  source                 = "../modules/rds"
  environment            = var.environment
  project_name           = var.project_name
  db_name                = "mydb"
  db_username            = "postgres"
  db_password            = var.db_password
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  subnet_ids             = module.vpc.public_subnet_ids
  engine_version         = "14.17"
  storage_type           = "gp2"
  storage_encrypted      = false
  backup_retention_days  = 0
  apply_immediately      = false
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
