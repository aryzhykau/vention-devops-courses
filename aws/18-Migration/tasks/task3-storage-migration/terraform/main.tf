provider "aws" {
  region = var.aws_region
}

# Source S3 Bucket
resource "aws_s3_bucket" "source" {
  bucket = "${var.project_name}-source-${data.aws_caller_identity.current.account_id}"
  
  tags = var.tags
}

# Destination S3 Bucket
resource "aws_s3_bucket" "destination" {
  bucket = "${var.project_name}-destination-${data.aws_caller_identity.current.account_id}"
  
  tags = var.tags
}

# Enable versioning for source bucket
resource "aws_s3_bucket_versioning" "source" {
  bucket = aws_s3_bucket.source.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable versioning for destination bucket
resource "aws_s3_bucket_versioning" "destination" {
  bucket = aws_s3_bucket.destination.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Replication Role
resource "aws_iam_role" "replication" {
  name = "${var.project_name}-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

# S3 Replication Policy
resource "aws_iam_role_policy" "replication" {
  name = "${var.project_name}-replication-policy"
  role = aws_iam_role.replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.source.arn
        ]
      },
      {
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.source.arn}/*"
        ]
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.destination.arn}/*"
        ]
      }
    ]
  })
}

# EBS Volume for migration
resource "aws_ebs_volume" "migration" {
  availability_zone = var.availability_zone
  size             = 30 # Free tier: 30 GB
  type             = "gp2"

  tags = merge(var.tags, {
    Name = "${var.project_name}-volume"
  })
}

# EBS Snapshot
resource "aws_ebs_snapshot" "migration" {
  volume_id = aws_ebs_volume.migration.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-snapshot"
  })
}

# CloudWatch Metric Alarm for S3
resource "aws_cloudwatch_metric_alarm" "s3_replication" {
  alarm_name          = "${var.project_name}-s3-replication"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ReplicationLatency"
  namespace           = "AWS/S3"
  period             = "300"
  statistic          = "Average"
  threshold          = "3600"
  alarm_description  = "This metric monitors S3 replication latency"
  alarm_actions      = [aws_sns_topic.notifications.arn]

  dimensions = {
    BucketName = aws_s3_bucket.source.id
  }
}

# SNS Topic for Notifications
resource "aws_sns_topic" "notifications" {
  name = "${var.project_name}-storage-notifications"
  tags = var.tags
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "storage" {
  name              = "/aws/storage/${var.project_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# AWS Backup Vault
resource "aws_backup_vault" "storage" {
  name = "${var.project_name}-backup-vault"
  tags = var.tags
}

# AWS Backup Plan
resource "aws_backup_plan" "storage" {
  name = "${var.project_name}-backup-plan"

  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.storage.name
    schedule          = "cron(0 5 ? * * *)"

    lifecycle {
      delete_after = var.backup_retention_days
    }
  }

  tags = var.tags
}

# Data source for current account ID
data "aws_caller_identity" "current" {} 