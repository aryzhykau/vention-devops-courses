# AWS RDS Best Practices

## Security Best Practices

### 1. Network Security Configuration
```hcl
# VPC Configuration
resource "aws_vpc" "database" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "database-vpc"
  }
}

# Private Subnet Configuration
resource "aws_subnet" "database" {
  count             = 2
  vpc_id            = aws_vpc.database.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "database-subnet-${count.index + 1}"
  }
}

# Security Group Configuration
resource "aws_security_group" "database" {
  name        = "database-sg"
  description = "Security group for RDS database"
  vpc_id      = aws_vpc.database.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### 2. Encryption Configuration
```hcl
# KMS Key for RDS
resource "aws_kms_key" "database" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "rds-encryption-key"
  }
}

# RDS Instance with Encryption
resource "aws_db_instance" "database" {
  identifier        = "production-db"
  engine            = "mysql"
  engine_version    = "8.0.28"
  instance_class    = "db.r5.large"
  allocated_storage = 100

  storage_encrypted = true
  kms_key_id       = aws_kms_key.database.arn

  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.database.name

  backup_retention_period = 7
  multi_az               = true

  # Enable SSL
  parameter_group_name = aws_db_parameter_group.database.name
}

# Parameter Group for SSL
resource "aws_db_parameter_group" "database" {
  family = "mysql8.0"
  name   = "production-params"

  parameter {
    name  = "require_secure_transport"
    value = "ON"
  }
}
```

## High Availability Best Practices

### 1. Multi-AZ Configuration
```hcl
# Multi-AZ RDS Instance
resource "aws_db_instance" "database" {
  identifier        = "production-db"
  engine            = "mysql"
  engine_version    = "8.0.28"
  instance_class    = "db.r5.large"
  allocated_storage = 100

  multi_az               = true
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.database.name
}

# Subnet Group for Multi-AZ
resource "aws_db_subnet_group" "database" {
  name       = "database-subnet-group"
  subnet_ids = aws_subnet.database[*].id

  tags = {
    Name = "Database subnet group"
  }
}
```

### 2. Read Replica Configuration
```hcl
# Read Replica
resource "aws_db_instance" "read_replica" {
  identifier     = "production-db-replica"
  instance_class = "db.r5.large"
  replicate_source_db = aws_db_instance.database.id

  vpc_security_group_ids = [aws_security_group.database.id]
  
  auto_minor_version_upgrade = true
  maintenance_window        = "Tue:04:00-Tue:05:00"

  tags = {
    Name = "Read Replica"
  }
}
```

## Performance Best Practices

### 1. Instance and Storage Configuration
```hcl
# Optimized RDS Instance
resource "aws_db_instance" "database" {
  identifier        = "production-db"
  engine            = "mysql"
  engine_version    = "8.0.28"
  instance_class    = "db.r5.large"
  
  # Storage Configuration
  allocated_storage     = 100
  max_allocated_storage = 1000
  storage_type          = "gp3"
  iops                 = 3000
  storage_throughput    = 125

  # Performance Configuration
  monitoring_interval = 1
  performance_insights_enabled = true
  performance_insights_retention_period = 7

  # Parameter Group
  parameter_group_name = aws_db_parameter_group.optimized.name
}

# Optimized Parameter Group
resource "aws_db_parameter_group" "optimized" {
  family = "mysql8.0"
  name   = "production-optimized-params"

  parameter {
    name  = "innodb_buffer_pool_size"
    value = "{DBInstanceClassMemory*3/4}"
  }

  parameter {
    name  = "max_connections"
    value = "1000"
  }
}
```

## Monitoring Best Practices

### 1. Enhanced Monitoring Configuration
```hcl
# IAM Role for Enhanced Monitoring
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "rds-enhanced-monitoring"

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

# RDS Instance with Enhanced Monitoring
resource "aws_db_instance" "database" {
  identifier        = "production-db"
  monitoring_interval = 1
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  performance_insights_enabled = true
  performance_insights_retention_period = 7
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  alarm_name          = "database-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors database CPU utilization"
  alarm_actions      = [aws_sns_topic.database_alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.database.id
  }
}
```

## Backup and Recovery Best Practices

### 1. Backup Configuration
```hcl
# RDS Instance with Backup Configuration
resource "aws_db_instance" "database" {
  identifier        = "production-db"
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  copy_tags_to_snapshot  = true
  
  deletion_protection    = true
  skip_final_snapshot    = false
  final_snapshot_identifier = "production-db-final-snapshot"

  # Enable automated backups
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
}

# Snapshot Policy
resource "aws_db_snapshot" "database" {
  db_instance_identifier = aws_db_instance.database.id
  db_snapshot_identifier = "production-db-snapshot"
}
```

## Cost Optimization Best Practices

### 1. Instance Sizing and Reserved Instances
```hcl
# Cost-Optimized RDS Instance
resource "aws_db_instance" "database" {
  identifier        = "production-db"
  instance_class    = "db.r5.large"
  
  # Storage Optimization
  allocated_storage     = 100
  max_allocated_storage = 1000
  storage_type          = "gp3"

  # Performance vs Cost
  multi_az             = true
  publicly_accessible  = false
}

# Reserved Instance Purchase (via AWS Console or API)
# Note: Reserved Instances cannot be created via Terraform
```

## Operational Excellence Best Practices

### 1. Tagging and Resource Management
```hcl
# RDS Instance with Tags
resource "aws_db_instance" "database" {
  identifier = "production-db"

  tags = {
    Environment = "Production"
    Department  = "Engineering"
    CostCenter  = "12345"
    Project     = "Core Infrastructure"
    Backup      = "Daily"
    Owner       = "Database Team"
  }
}
```

### 2. Maintenance Configuration
```hcl
# RDS Instance with Maintenance Configuration
resource "aws_db_instance" "database" {
  identifier = "production-db"

  maintenance_window = "Mon:04:00-Mon:05:00"
  backup_window     = "03:00-04:00"

  auto_minor_version_upgrade = true
  allow_major_version_upgrade = false
}
```

## Compliance Best Practices

### 1. Audit Configuration
```hcl
# Parameter Group with Audit Logging
resource "aws_db_parameter_group" "audit" {
  family = "mysql8.0"
  name   = "production-audit-params"

  parameter {
    name  = "general_log"
    value = "1"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "log_output"
    value = "FILE"
  }
}

# RDS Instance with Audit Configuration
resource "aws_db_instance" "database" {
  identifier = "production-db"

  parameter_group_name = aws_db_parameter_group.audit.name
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  monitoring_interval = 1
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn
}
```

### 2. Compliance Monitoring
```hcl
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
}

# CloudWatch Logs Metric Filter
resource "aws_cloudwatch_log_metric_filter" "database_changes" {
  name           = "database-changes"
  pattern        = "[timestamp, event_type=\"ModifyDBInstance\"]"
  log_group_name = "/aws/rds/instance/${aws_db_instance.database.id}/audit"

  metric_transformation {
    name      = "DatabaseConfigurationChanges"
    namespace = "CustomMetrics/RDS"
    value     = "1"
  }
}
``` 