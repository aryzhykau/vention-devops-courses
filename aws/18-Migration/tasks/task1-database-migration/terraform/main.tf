provider "aws" {
  region = var.aws_region
}

# VPC and Networking
resource "aws_vpc" "dms_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-vpc"
  })
}

# Subnets for DMS
resource "aws_subnet" "dms_subnet" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.dms_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${var.project_name}-subnet-${count.index + 1}"
  })
}

# DMS Replication Subnet Group
resource "aws_dms_replication_subnet_group" "dms" {
  replication_subnet_group_description = "DMS replication subnet group"
  replication_subnet_group_id         = "${var.project_name}-subnet-group"
  subnet_ids                          = aws_subnet.dms_subnet[*].id

  tags = var.tags
}

# DMS Replication Instance
resource "aws_dms_replication_instance" "dms" {
  allocated_storage                   = 20
  apply_immediately                   = true
  auto_minor_version_upgrade         = true
  availability_zone                  = var.availability_zones[0]
  engine_version                     = "3.4.7"
  multi_az                          = false
  publicly_accessible               = false
  replication_instance_class        = "dms.t2.micro"
  replication_instance_id           = "${var.project_name}-dms-instance"
  replication_subnet_group_id       = aws_dms_replication_subnet_group.dms.id
  vpc_security_group_ids           = [aws_security_group.dms.id]

  tags = var.tags
}

# Security Group for DMS
resource "aws_security_group" "dms" {
  name_prefix = "${var.project_name}-dms-sg"
  vpc_id      = aws_vpc.dms_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# S3 Bucket for Schema Storage
resource "aws_s3_bucket" "schema_storage" {
  bucket = "${var.project_name}-schema-storage-${data.aws_caller_identity.current.account_id}"
  
  tags = var.tags
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "schema_storage" {
  bucket = aws_s3_bucket.schema_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# CloudWatch Log Group for DMS
resource "aws_cloudwatch_log_group" "dms" {
  name              = "/aws/dms/${var.project_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# SNS Topic for DMS Notifications
resource "aws_sns_topic" "dms_notifications" {
  name = "${var.project_name}-dms-notifications"
  tags = var.tags
}

# CloudWatch Alarm for DMS
resource "aws_cloudwatch_metric_alarm" "dms_cpu" {
  alarm_name          = "${var.project_name}-dms-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/DMS"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors DMS CPU utilization"
  alarm_actions      = [aws_sns_topic.dms_notifications.arn]

  dimensions = {
    ReplicationInstanceIdentifier = aws_dms_replication_instance.dms.id
  }

  tags = var.tags
}

# Data source for current account ID
data "aws_caller_identity" "current" {} 