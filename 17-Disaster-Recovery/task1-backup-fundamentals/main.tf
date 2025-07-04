module "vpc" {
  source                = "./modules/vpc"
  cidr_block            = "10.0.0.0/16"
  public_subnet_cidr_a  = "10.0.10.0/24"
  public_subnet_cidr_b  = "10.0.2.0/24"
  availability_zone_a   = "eu-central-1a"
  availability_zone_b   = "eu-central-1b"
}

module "ec2" {
  source        = "./modules/ec2"
  ami           = "ami-03cceb19490f64e93"  
  instance_type = "t2.micro"
  subnet_id     = module.vpc.subnet_ids[0]
}


module "rds" {
  source         = "./modules/rds"
  instance_class = "db.t3.micro"
  username       = var.rds_username
  password       = var.rds_password
  subnet_ids     = module.vpc.subnet_ids     # Pass both subnets
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
}

module "cloudfront" {
  source    = "./modules/cloudfront"
  s3_domain = "${module.s3.bucket_name}.s3.amazonaws.com"
}

