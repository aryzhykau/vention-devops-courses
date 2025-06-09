# Read Replica in Primary Region
resource "aws_db_instance" "replica" {
  identifier     = "ha-mysql-replica"
  instance_class = var.db_instance_class
  replicate_source_db = aws_db_instance.main.id

  multi_az               = true
  storage_encrypted      = true
  kms_key_id            = aws_kms_key.rds.arn
  storage_type          = "gp3"
  iops                  = 3000
  storage_throughput    = 125

  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.replica.name
  option_group_name      = aws_db_option_group.main.name

  auto_minor_version_upgrade = true
  maintenance_window        = "Tue:04:00-Tue:05:00"

  monitoring_interval = 1
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  performance_insights_enabled    = true

  tags = merge(var.tags, {
    Name = "ha-mysql-replica"
  })
}

# Parameter Group for Read Replica
resource "aws_db_parameter_group" "replica" {
  family = "mysql8.0"
  name   = "ha-rds-replica-params"

  parameter {
    name  = "read_only"
    value = "1"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  tags = merge(var.tags, {
    Name = "HA RDS replica parameter group"
  })
}

# Cross-Region Read Replica
resource "aws_db_instance" "cross_region_replica" {
  provider = aws.dr_region

  identifier     = "ha-mysql-cross-region-replica"
  instance_class = var.db_instance_class
  replicate_source_db = aws_db_instance.main.arn

  multi_az               = true
  storage_encrypted      = true
  kms_key_id            = aws_kms_key.rds_dr.arn
  storage_type          = "gp3"
  iops                  = 3000
  storage_throughput    = 125

  vpc_security_group_ids = [aws_security_group.rds_dr.id]
  parameter_group_name   = aws_db_parameter_group.replica_dr.name
  option_group_name      = aws_db_option_group.main_dr.name

  auto_minor_version_upgrade = true
  maintenance_window        = "Wed:04:00-Wed:05:00"

  monitoring_interval = 1
  monitoring_role_arn = aws_iam_role.rds_monitoring_dr.arn

  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  performance_insights_enabled    = true

  tags = merge(var.tags, {
    Name = "ha-mysql-cross-region-replica"
  })
}

# DR Region Resources
provider "aws" {
  alias  = "dr_region"
  region = var.dr_region
}

# KMS Key in DR Region
resource "aws_kms_key" "rds_dr" {
  provider = aws.dr_region

  description             = "KMS key for RDS encryption in DR region"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name = "ha-rds-dr-key"
  })
}

# VPC in DR Region
resource "aws_vpc" "dr" {
  provider = aws.dr_region

  cidr_block           = var.dr_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "ha-rds-dr-vpc"
  })
}

# Private Subnets in DR Region
resource "aws_subnet" "private_dr" {
  provider = aws.dr_region
  count    = 2

  vpc_id            = aws_vpc.dr.id
  cidr_block        = cidrsubnet(var.dr_vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.dr.names[count.index]

  tags = merge(var.tags, {
    Name = "ha-rds-dr-private-${count.index + 1}"
  })
}

# Security Group in DR Region
resource "aws_security_group" "rds_dr" {
  provider = aws.dr_region

  name        = "ha-rds-dr-sg"
  description = "Security group for RDS DR instance"
  vpc_id      = aws_vpc.dr.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.dr_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "ha-rds-dr-sg"
  })
}

# Parameter Group in DR Region
resource "aws_db_parameter_group" "replica_dr" {
  provider = aws.dr_region
  family   = "mysql8.0"
  name     = "ha-rds-dr-params"

  parameter {
    name  = "read_only"
    value = "1"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  tags = merge(var.tags, {
    Name = "HA RDS DR parameter group"
  })
}

# Option Group in DR Region
resource "aws_db_option_group" "main_dr" {
  provider = aws.dr_region

  name                     = "ha-rds-dr-options"
  option_group_description = "Option group for HA RDS DR instance"
  engine_name             = "mysql"
  major_engine_version    = "8.0"

  option {
    option_name = "MARIADB_AUDIT_PLUGIN"

    option_settings {
      name  = "SERVER_AUDIT_EVENTS"
      value = "CONNECT,QUERY,TABLE"
    }
  }

  tags = merge(var.tags, {
    Name = "HA RDS DR option group"
  })
}

# Monitoring Role in DR Region
resource "aws_iam_role" "rds_monitoring_dr" {
  provider = aws.dr_region
  name     = "ha-rds-monitoring-dr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "RDS Monitoring DR Role"
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_dr" {
  provider   = aws.dr_region
  role       = aws_iam_role.rds_monitoring_dr.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# CloudWatch Alarm for DR Replica Lag
resource "aws_cloudwatch_metric_alarm" "replica_lag_dr" {
  provider = aws.dr_region

  alarm_name          = "ha-rds-dr-replica-lag"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "ReplicaLag"
  namespace           = "AWS/RDS"
  period             = "60"
  statistic          = "Average"
  threshold          = "300" # 5 minutes
  alarm_description  = "This metric monitors the replication lag for cross-region replica"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.cross_region_replica.id
  }

  tags = merge(var.tags, {
    Name = "DR Replica Lag Alarm"
  })
}

# Data Source for DR Region AZs
data "aws_availability_zones" "dr" {
  provider = aws.dr_region
  state    = "available"
} 