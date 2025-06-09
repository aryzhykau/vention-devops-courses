# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "audit" {
  name              = "/aws/rds/audit/${aws_db_instance.secure.identifier}"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.rds_encryption.arn

  tags = merge(var.tags, {
    Name = "RDS Audit Logs"
  })
}

resource "aws_cloudwatch_log_group" "error" {
  name              = "/aws/rds/error/${aws_db_instance.secure.identifier}"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.rds_encryption.arn

  tags = merge(var.tags, {
    Name = "RDS Error Logs"
  })
}

resource "aws_cloudwatch_log_group" "general" {
  name              = "/aws/rds/general/${aws_db_instance.secure.identifier}"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.rds_encryption.arn

  tags = merge(var.tags, {
    Name = "RDS General Logs"
  })
}

resource "aws_cloudwatch_log_group" "slowquery" {
  name              = "/aws/rds/slowquery/${aws_db_instance.secure.identifier}"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.rds_encryption.arn

  tags = merge(var.tags, {
    Name = "RDS Slow Query Logs"
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "secure-rds-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors RDS CPU utilization"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.secure.id
  }

  tags = merge(var.tags, {
    Name = "RDS CPU Alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space" {
  alarm_name          = "secure-rds-free-storage-space"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = "5000000000" # 5GB in bytes
  alarm_description  = "This metric monitors RDS free storage space"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.secure.id
  }

  tags = merge(var.tags, {
    Name = "RDS Storage Alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "connection_count" {
  alarm_name          = "secure-rds-connection-count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = "100"
  alarm_description  = "This metric monitors the number of database connections"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.secure.id
  }

  tags = merge(var.tags, {
    Name = "RDS Connection Alarm"
  })
}

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name              = "secure-rds-alerts"
  kms_master_key_id = aws_kms_key.rds_encryption.id

  tags = merge(var.tags, {
    Name = "RDS Alerts Topic"
  })
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "alerts" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchAlarms"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}

# Config Rules
resource "aws_config_config_rule" "rds_encryption" {
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

resource "aws_config_config_rule" "rds_public_access" {
  name = "rds-instance-public-access-check"

  source {
    owner             = "AWS"
    source_identifier = "RDS_INSTANCE_PUBLIC_ACCESS_CHECK"
  }

  scope {
    compliance_resource_types = ["AWS::RDS::DBInstance"]
  }

  tags = merge(var.tags, {
    Name = "RDS Public Access Rule"
  })
}

resource "aws_config_config_rule" "rds_multi_az" {
  name = "rds-multi-az-support"

  source {
    owner             = "AWS"
    source_identifier = "RDS_MULTI_AZ_SUPPORT"
  }

  scope {
    compliance_resource_types = ["AWS::RDS::DBInstance"]
  }

  tags = merge(var.tags, {
    Name = "RDS Multi-AZ Rule"
  })
}

# GuardDuty
resource "aws_guardduty_detector" "main" {
  enable = true

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }

  tags = merge(var.tags, {
    Name = "RDS Security Detector"
  })
}

# Security Hub
resource "aws_securityhub_account" "main" {}

resource "aws_securityhub_standards_subscription" "pci" {
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/pci-dss/v/3.2.1"
  depends_on    = [aws_securityhub_account.main]
}

resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/cis-aws-foundations-benchmark/v/1.2.0"
  depends_on    = [aws_securityhub_account.main]
} 