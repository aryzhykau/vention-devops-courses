provider "aws" {
  region = var.aws_region
}

# AWS Backup vault
resource "aws_backup_vault" "backup_vault" {
  name = "${var.project_name}-vault"
  tags = var.tags
}

# AWS Backup plan
resource "aws_backup_plan" "backup_plan" {
  name = "${var.project_name}-backup-plan"

  rule {
    rule_name         = "daily_backup_rule"
    target_vault_name = aws_backup_vault.backup_vault.name
    schedule          = var.backup_schedule

    lifecycle {
      delete_after = var.backup_retention_days
    }
  }

  tags = var.tags
}

# S3 bucket for additional backups
resource "aws_s3_bucket" "backup_bucket" {
  bucket = "${var.project_name}-backups-${data.aws_caller_identity.current.account_id}"
  
  tags = var.tags
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "backup_bucket_versioning" {
  bucket = aws_s3_bucket.backup_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 lifecycle rule
resource "aws_s3_bucket_lifecycle_configuration" "backup_lifecycle" {
  bucket = aws_s3_bucket.backup_bucket.id

  rule {
    id     = "backup_retention"
    status = "Enabled"

    expiration {
      days = var.backup_retention_days
    }
  }
}

# CloudWatch monitoring
resource "aws_cloudwatch_metric_alarm" "backup_failure_alarm" {
  alarm_name          = "${var.project_name}-backup-failure"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BackupJobsFailed"
  namespace           = "AWS/Backup"
  period             = "86400"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "This metric monitors failed backup jobs"
  alarm_actions      = [aws_sns_topic.backup_notifications.arn]

  dimensions = {
    BackupVaultName = aws_backup_vault.backup_vault.name
  }
}

# SNS topic for notifications
resource "aws_sns_topic" "backup_notifications" {
  name = "${var.project_name}-backup-notifications"
  tags = var.tags
}

# Data source for current account ID
data "aws_caller_identity" "current" {} 