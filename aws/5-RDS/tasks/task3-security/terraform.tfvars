aws_region = "us-west-2"
vpc_cidr = "10.0.0.0/16"
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
db_instance_class = "db.t3.medium"
db_name = "securedb"
database_domain = "db.example.com"

tags = {
  Environment = "Production"
  Project     = "RDS Security Implementation"
  Terraform   = "true"
  Owner       = "DevOps Team"
  CostCenter  = "12345"
  Compliance  = "PCI-DSS"
} 