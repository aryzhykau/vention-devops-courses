# Manual Snapshot
resource "aws_db_snapshot" "manual" {
  db_instance_identifier = aws_db_instance.main.id
  db_snapshot_identifier = "ha-mysql-manual-snapshot"

  tags = merge(var.tags, {
    Name = "HA MySQL Manual Snapshot"
  })
}

# Cross-Region Snapshot Copy
resource "aws_db_snapshot_copy" "dr" {
  provider = aws.dr_region

  source_db_snapshot_identifier = aws_db_snapshot.manual.arn
  target_db_snapshot_identifier = "ha-mysql-dr-snapshot"
  kms_key_id                   = aws_kms_key.rds_dr.arn

  tags = merge(var.tags, {
    Name = "HA MySQL DR Snapshot"
  })
}

# Lifecycle Policy for Automated Backups
resource "aws_dlm_lifecycle_policy" "rds_backup" {
  description        = "RDS backup lifecycle policy"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state             = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "Daily RDS Volume Backups"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times        = ["03:00"]
      }

      retain_rule {
        count = var.backup_retention_period
      }

      copy_tags = true
    }

    target_tags = {
      Backup = "true"
    }
  }

  tags = merge(var.tags, {
    Name = "RDS Backup Lifecycle Policy"
  })
}

# IAM Role for DLM
resource "aws_iam_role" "dlm_lifecycle_role" {
  name = "dlm-lifecycle-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "dlm.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for DLM
resource "aws_iam_role_policy" "dlm_lifecycle" {
  name = "dlm-lifecycle-policy"
  role = aws_iam_role.dlm_lifecycle_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateTags"
        ]
        Resource = "arn:aws:ec2:*::snapshot/*"
      }
    ]
  })
}

# S3 Bucket for Backup Storage
resource "aws_s3_bucket" "backup" {
  bucket = "ha-rds-backup-${data.aws_caller_identity.current.account_id}"

  tags = merge(var.tags, {
    Name = "HA RDS Backup Bucket"
  })
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "backup" {
  bucket = aws_s3_bucket.backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.rds.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# S3 Bucket Lifecycle Rule
resource "aws_s3_bucket_lifecycle_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    id     = "backup_retention"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "backup" {
  bucket = aws_s3_bucket.backup.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforceSSLOnly"
        Effect = "Deny"
        Principal = "*"
        Action   = "s3:*"
        Resource = [
          aws_s3_bucket.backup.arn,
          "${aws_s3_bucket.backup.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  })
}

# Data Source for AWS Account ID
data "aws_caller_identity" "current" {} 