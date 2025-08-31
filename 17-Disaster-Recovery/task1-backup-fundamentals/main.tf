module "vpc" {
  source                = "./modules/vpc"
  cidr_block            = "10.0.0.0/16"
  public_subnet_cidr_a  = "10.0.10.0/24"
  public_subnet_cidr_b  = "10.0.2.0/24"
  availability_zone_a   = "eu-central-1a"
  availability_zone_b   = "eu-central-1b"
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
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
    Name = "alb-sg"
  }
}

module "loadbalancer" {
  source            = "./modules/loadbalancer"
  subnet_ids        = module.vpc.subnet_ids
  security_group_id = aws_security_group.alb_sg.id
  vpc_id            = module.vpc.vpc_id
  instance_id       = module.ec2.instance_id
  environment       = "dev"
}

module "ec2" {
  source           = "./modules/ec2"
  ami              = "ami-0767046d1677be5a0"
  instance_type    = "t2.micro"
  subnet_id        = module.vpc.subnet_ids[0]
  vpc_id           = module.vpc.vpc_id
  alb_sg_id        = aws_security_group.alb_sg.id
  target_group_arn = module.loadbalancer.target_group_arn
}

# Optional: Skip RDS for now to save cost
# module "rds" {
#   source         = "./modules/rds"
#   instance_class = "db.t3.micro"
#   username       = var.rds_username
#   password       = var.rds_password
#   subnet_ids     = module.vpc.subnet_ids
# }

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
}

module "cloudfront" {
  source    = "./modules/cloudfront"
  s3_domain = "${module.s3.bucket_name}.s3.amazonaws.com"
}




