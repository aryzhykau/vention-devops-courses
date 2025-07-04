resource "aws_db_subnet_group" "default" {
  name       = "db-subnet-group"
  subnet_ids = var.subnet_ids  # Now passing a list from root

  tags = {
    Name = "DB subnet group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier             = "postgres-db"
  engine                 = "postgres"
  instance_class         = var.instance_class
  username               = var.username
  password               = var.password
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.default.name
  skip_final_snapshot    = true
  publicly_accessible    = true
}


