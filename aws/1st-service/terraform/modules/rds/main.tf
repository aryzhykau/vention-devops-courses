locals {
  name_db_subnet = "${var.project_name}-${var.environment}-db-subnet-group"
  name_db        = "${var.project_name}-${var.environment}-db"
}

resource "aws_db_subnet_group" "this" {
  name       = local.name_db_subnet
  subnet_ids = var.subnet_ids
  tags       = { Name = local.name_db_subnet, Environment = var.environment, Project = var.project_name, ManagedBy = "Terraform" }
}

resource "aws_db_instance" "this" {
  identifier                   = local.name_db
  engine                       = var.engine
  engine_version               = var.engine_version
  instance_class               = var.instance_class
  allocated_storage            = var.allocated_storage
  storage_type                 = var.storage_type
  db_name                      = var.db_name
  username                     = var.db_username
  password                     = var.db_password
  port                         = var.port
  parameter_group_name         = var.parameter_group_name
  db_subnet_group_name         = aws_db_subnet_group.this.name
  vpc_security_group_ids       = var.vpc_security_group_ids
  publicly_accessible          = var.publicly_accessible
  multi_az                     = var.multi_az
  storage_encrypted            = var.storage_encrypted
  performance_insights_enabled = var.performance_insights
  backup_retention_period      = var.backup_retention_days
  maintenance_window           = var.maintenance_window
  backup_window                = var.backup_window
  deletion_protection          = var.deletion_protection
  auto_minor_version_upgrade   = var.auto_minor_upgrade
  apply_immediately            = var.apply_immediately
  skip_final_snapshot          = true
  final_snapshot_identifier    = null
  max_allocated_storage        = var.max_allocated_storage == 0 ? null : var.max_allocated_storage
  tags                         = { Name = local.name_db, Environment = var.environment, Project = var.project_name, ManagedBy = "Terraform" }
}

