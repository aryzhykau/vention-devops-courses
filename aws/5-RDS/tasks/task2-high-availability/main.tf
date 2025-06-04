# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Data Sources
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "ha-rds-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ha-rds-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "ha-rds-public-${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "ha-rds-private-${count.index + 1}"
  }
}

# NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "ha-rds-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "ha-rds-nat"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "ha-rds-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "ha-rds-private-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Security Group
resource "aws_security_group" "rds" {
  name        = "ha-rds-sg"
  description = "Security group for RDS Multi-AZ instance"
  vpc_id      = aws_vpc.main.id

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

  tags = {
    Name = "ha-rds-sg"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "ha-rds-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "HA RDS subnet group"
  }
}

# Parameter Group
resource "aws_db_parameter_group" "main" {
  family = "mysql8.0"
  name   = "ha-rds-params"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "max_connections"
    value = "1000"
  }

  tags = {
    Name = "HA RDS parameter group"
  }
}

# Option Group
resource "aws_db_option_group" "main" {
  name                     = "ha-rds-options"
  option_group_description = "Option group for HA RDS instance"
  engine_name             = "mysql"
  major_engine_version    = "8.0"

  option {
    option_name = "MARIADB_AUDIT_PLUGIN"

    option_settings {
      name  = "SERVER_AUDIT_EVENTS"
      value = "CONNECT,QUERY,TABLE"
    }
  }

  tags = {
    Name = "HA RDS option group"
  }
}

# KMS Key for Encryption
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "ha-rds-key"
  }
}

# Primary RDS Instance
resource "aws_db_instance" "main" {
  identifier        = "ha-mysql-primary"
  engine            = "mysql"
  engine_version    = "8.0.28"
  instance_class    = var.db_instance_class
  allocated_storage = var.allocated_storage

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  multi_az               = true
  storage_encrypted      = true
  kms_key_id            = aws_kms_key.rds.arn
  storage_type          = "gp3"
  iops                  = 3000
  storage_throughput    = 125

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name
  option_group_name      = aws_db_option_group.main.name

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  deletion_protection = true
  skip_final_snapshot = false
  final_snapshot_identifier = "ha-mysql-final-snapshot"

  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  monitoring_interval            = 1
  monitoring_role_arn           = aws_iam_role.rds_monitoring.arn
  performance_insights_enabled   = true

  tags = {
    Name = "ha-mysql-primary"
  }
}

# Enhanced Monitoring Role
resource "aws_iam_role" "rds_monitoring" {
  name = "ha-rds-monitoring-role"

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
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "replica_lag" {
  alarm_name          = "ha-rds-replica-lag"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "ReplicaLag"
  namespace           = "AWS/RDS"
  period             = "60"
  statistic          = "Average"
  threshold          = "300" # 5 minutes
  alarm_description  = "This metric monitors the replication lag"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.replica.id
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "ha-rds-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors RDS CPU utilization"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space" {
  alarm_name          = "ha-rds-free-storage-space"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = "5000000000" # 5GB in bytes
  alarm_description  = "This metric monitors RDS free storage space"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
}

# Event Subscription
resource "aws_db_event_subscription" "main" {
  name      = "ha-rds-event-subscription"
  sns_topic = aws_sns_topic.rds_events.arn

  source_type = "db-instance"
  source_ids  = [aws_db_instance.main.id, aws_db_instance.replica.id]

  event_categories = [
    "availability",
    "deletion",
    "failover",
    "failure",
    "low storage",
    "maintenance",
    "recovery"
  ]
}

# SNS Topic for RDS Events
resource "aws_sns_topic" "rds_events" {
  name = "ha-rds-events"
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "rds_events" {
  arn = aws_sns_topic.rds_events.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRDSEvents"
        Effect = "Allow"
        Principal = {
          Service = "events.rds.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.rds_events.arn
      }
    ]
  })
} 