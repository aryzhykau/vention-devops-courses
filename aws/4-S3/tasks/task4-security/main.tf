# Configure AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Random string for unique names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "s3-security-vpc"
  }
}

# Create subnet
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "s3-security-subnet"
  }
}

# Create S3 VPC endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"

  tags = {
    Name = "s3-endpoint"
  }
}

# Create KMS key
resource "aws_kms_key" "s3" {
  description             = "KMS key for S3 encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}

# Create KMS alias
resource "aws_kms_alias" "s3" {
  name          = "alias/s3-encryption-${random_string.suffix.result}"
  target_key_id = aws_kms_key.s3.key_id
}

# Create S3 bucket
resource "aws_s3_bucket" "main" {
  bucket = "secure-bucket-${random_string.suffix.result}"

  tags = {
    Name        = "SecureBucket"
    Environment = "Training"
    Project     = "AWS-Course"
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Create logging bucket
resource "aws_s3_bucket" "logs" {
  bucket = "logs-bucket-${random_string.suffix.result}"

  tags = {
    Name        = "LogsBucket"
    Environment = "Training"
    Project     = "AWS-Course"
  }
}

# Enable logging
resource "aws_s3_bucket_logging" "main" {
  bucket = aws_s3_bucket.main.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-logs/"
}

# Create CloudTrail
resource "aws_cloudtrail" "s3_trail" {
  name                          = "s3-audit-trail"
  s3_bucket_name               = aws_s3_bucket.logs.id
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_logging               = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["${aws_s3_bucket.main.arn}/"]
    }
  }
}

# Create S3 access point
resource "aws_s3_access_point" "example" {
  bucket = aws_s3_bucket.main.id
  name   = "secure-access-point"

  vpc_configuration {
    vpc_id = aws_vpc.main.id
  }

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowVPCAccessOnly"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.main.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceVpc" = aws_vpc.main.id
          }
        }
      }
    ]
  })
}

# Create bucket policy
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyUnencryptedObjectUploads"
        Effect = "Deny"
        Principal = {
          AWS = "*"
        }
        Action = "s3:PutObject"
        Resource = [
          "${aws_s3_bucket.main.arn}/*"
        ]
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      },
      {
        Sid    = "DenyNonVPCAccess"
        Effect = "Deny"
        Principal = {
          AWS = "*"
        }
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.main.arn,
          "${aws_s3_bucket.main.arn}/*"
        ]
        Condition = {
          StringNotEquals = {
            "aws:SourceVpc" = aws_vpc.main.id
          }
        }
      }
    ]
  })
}

# Create CloudWatch alarms
resource "aws_cloudwatch_metric_alarm" "unauthorized_access" {
  alarm_name          = "s3-unauthorized-access"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "AuthorizationErrorCount"
  namespace           = "AWS/S3"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "This metric monitors unauthorized access attempts"
  alarm_actions      = []  # Add SNS topic ARN here if needed

  dimensions = {
    BucketName = aws_s3_bucket.main.id
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Outputs
output "bucket_name" {
  description = "Name of the secure bucket"
  value       = aws_s3_bucket.main.id
}

output "access_point_alias" {
  description = "Access point alias"
  value       = aws_s3_access_point.example.alias
}

output "kms_key_id" {
  description = "ID of the KMS key"
  value       = aws_kms_key.s3.id
}

output "vpc_endpoint_id" {
  description = "ID of the VPC endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = aws_cloudtrail.s3_trail.arn
} 