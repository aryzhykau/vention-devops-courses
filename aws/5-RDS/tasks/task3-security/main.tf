# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Data Sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# VPC Configuration
resource "aws_vpc" "secure" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "secure-rds-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "secure" {
  vpc_id = aws_vpc.secure.id

  tags = merge(var.tags, {
    Name = "secure-rds-igw"
  })
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.secure.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.tags, {
    Name = "secure-rds-private-${count.index + 1}"
  })
}

# Network ACLs
resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.secure.id
  subnet_ids = aws_subnet.private[*].id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 3306
    to_port    = 3306
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(var.tags, {
    Name = "secure-rds-nacl"
  })
}

# Security Group
resource "aws_security_group" "secure" {
  name        = "secure-rds-sg"
  description = "Security group for secure RDS instance"
  vpc_id      = aws_vpc.secure.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "Secure RDS Security Group"
  })
}

# Application Security Group
resource "aws_security_group" "app" {
  name        = "secure-rds-app-sg"
  description = "Security group for application servers"
  vpc_id      = aws_vpc.secure.id

  tags = merge(var.tags, {
    Name = "Application Security Group"
  })
}

# DB Subnet Group
resource "aws_db_subnet_group" "secure" {
  name        = "secure-rds-subnet-group"
  description = "Subnet group for secure RDS instance"
  subnet_ids  = aws_subnet.private[*].id

  tags = merge(var.tags, {
    Name = "Secure RDS Subnet Group"
  })
}

# KMS Key
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                 = data.aws_iam_policy_document.kms.json

  tags = merge(var.tags, {
    Name = "secure-rds-key"
  })
}

# KMS Key Policy
data "aws_iam_policy_document" "kms" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow RDS to use the key"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "rds.amazonaws.com"
      ]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

# Parameter Group
resource "aws_db_parameter_group" "secure" {
  family = "mysql8.0"
  name   = "secure-rds-params"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2"
  }

  parameter {
    name  = "log_output"
    value = "FILE"
  }

  parameter {
    name  = "general_log"
    value = "1"
  }

  tags = merge(var.tags, {
    Name = "Secure RDS Parameter Group"
  })
}

# Option Group
resource "aws_db_option_group" "secure" {
  name                     = "secure-rds-options"
  option_group_description = "Option group for secure RDS instance"
  engine_name             = "mysql"
  major_engine_version    = "8.0"

  option {
    option_name = "MARIADB_AUDIT_PLUGIN"

    option_settings {
      name  = "SERVER_AUDIT_EVENTS"
      value = "CONNECT,QUERY,TABLE,QUERY_DDL,QUERY_DML,QUERY_DCL"
    }
  }

  tags = merge(var.tags, {
    Name = "Secure RDS Option Group"
  })
}

# RDS Instance
resource "aws_db_instance" "secure" {
  identifier        = "secure-mysql-instance"
  engine           = "mysql"
  engine_version   = "8.0"
  instance_class   = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true
  kms_key_id       = aws_kms_key.rds.arn

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.secure.name
  vpc_security_group_ids = [aws_security_group.secure.id]
  parameter_group_name   = aws_db_parameter_group.secure.name
  option_group_name      = aws_db_option_group.secure.name

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  auto_minor_version_upgrade = true
  copy_tags_to_snapshot     = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "secure-mysql-final-snapshot"

  performance_insights_enabled    = true
  performance_insights_retention_period = 7
  monitoring_interval            = 1
  monitoring_role_arn           = aws_iam_role.rds_monitoring.arn

  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  iam_database_authentication_enabled = true

  deletion_protection = true

  tags = merge(var.tags, {
    Name = "Secure RDS Instance"
  })
}

# Enhanced Monitoring Role
resource "aws_iam_role" "rds_monitoring" {
  name = "secure-rds-monitoring-role"

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
    Name = "RDS Monitoring Role"
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "rds_audit" {
  name              = "/aws/rds/instance/${aws_db_instance.secure.identifier}/audit"
  retention_in_days = 30

  tags = merge(var.tags, {
    Name = "RDS Audit Logs"
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "secure-rds-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors RDS CPU utilization"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.secure.id
  }

  tags = merge(var.tags, {
    Name = "RDS CPU Alarm"
  })
}

# Flow Logs
resource "aws_flow_log" "vpc" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.secure.id

  tags = merge(var.tags, {
    Name = "VPC Flow Logs"
  })
}

# Flow Logs Role
resource "aws_iam_role" "vpc_flow_logs" {
  name = "vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "VPC Flow Logs Role"
  })
}

# Flow Logs Policy
resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# Flow Logs Log Group
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flow-logs"
  retention_in_days = 30

  tags = merge(var.tags, {
    Name = "VPC Flow Logs"
  })
}

# AWS Config Rule
resource "aws_config_config_rule" "rds_encrypted" {
  name = "rds-storage-encrypted"

  source {
    owner             = "AWS"
    source_identifier = "RDS_STORAGE_ENCRYPTED"
  }

  scope {
    compliance_resource_types = ["AWS::RDS::DBInstance"]
  }

  tags = merge(var.tags, {
    Name = "RDS Encryption Rule"
  })
}

# SNS Topic for Notifications
resource "aws_sns_topic" "security_alerts" {
  name = "rds-security-alerts"

  tags = merge(var.tags, {
    Name = "RDS Security Alerts"
  })
}

# Event Subscription
resource "aws_db_event_subscription" "security_events" {
  name      = "rds-security-events"
  sns_topic = aws_sns_topic.security_alerts.arn

  source_type = "db-instance"
  source_ids  = [aws_db_instance.secure.id]

  event_categories = [
    "failure",
    "failover",
    "low storage",
    "maintenance",
    "notification",
    "recovery",
    "restoration"
  ]

  tags = merge(var.tags, {
    Name = "RDS Security Events"
  })
}

# Outputs
output "db_instance_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.secure.endpoint
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.secure.arn
}

output "db_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.secure.id
}

output "db_subnet_group_id" {
  description = "The ID of the DB subnet group"
  value       = aws_db_subnet_group.secure.id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.secure.id
}

output "parameter_group_id" {
  description = "The ID of the parameter group"
  value       = aws_db_parameter_group.secure.id
}

output "option_group_id" {
  description = "The ID of the option group"
  value       = aws_db_option_group.secure.id
}

output "kms_key_id" {
  description = "The ID of the KMS key"
  value       = aws_kms_key.rds.id
}

output "monitoring_role_arn" {
  description = "The ARN of the monitoring role"
  value       = aws_iam_role.rds_monitoring.arn
} 