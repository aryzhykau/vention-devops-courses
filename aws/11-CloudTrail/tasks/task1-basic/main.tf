# Basic CloudTrail Setup

# S3 Bucket for CloudTrail Logs
resource "aws_s3_bucket" "trail" {
  bucket        = "cloudtrail-logs-${var.environment}-${data.aws_caller_identity.current.account_id}"
  force_destroy = false

  tags = {
    Environment = var.environment
    Service     = "CloudTrail"
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "trail" {
  bucket = aws_s3_bucket.trail.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "trail" {
  bucket = aws_s3_bucket.trail.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "trail" {
  bucket = aws_s3_bucket.trail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.trail.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.trail.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${var.environment}"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    Service     = "CloudTrail"
  }
}

# IAM Role for CloudTrail to CloudWatch Logs
resource "aws_iam_role" "cloudtrail_cloudwatch" {
  name = "cloudtrail-cloudwatch-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Role Policy for CloudTrail to CloudWatch Logs
resource "aws_iam_role_policy" "cloudtrail_cloudwatch" {
  name = "cloudtrail-cloudwatch-policy"
  role = aws_iam_role.cloudtrail_cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      }
    ]
  })
}

# SNS Topic for CloudTrail Notifications
resource "aws_sns_topic" "cloudtrail" {
  name = "cloudtrail-notifications-${var.environment}"

  tags = {
    Environment = var.environment
    Service     = "CloudTrail"
  }
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "cloudtrail" {
  arn = aws_sns_topic.cloudtrail.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailSNSPolicy"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.cloudtrail.arn
      }
    ]
  })
}

# CloudTrail
resource "aws_cloudtrail" "main" {
  name                          = "main-trail-${var.environment}"
  s3_bucket_name               = aws_s3_bucket.trail.id
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_logging               = true
  sns_topic_name              = aws_sns_topic.cloudtrail.name
  cloud_watch_logs_group_arn   = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn    = aws_iam_role.cloudtrail_cloudwatch.arn
  enable_log_file_validation   = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = {
    Environment = var.environment
    Service     = "CloudTrail"
  }
}

# CloudWatch Metric Filter for Root Account Usage
resource "aws_cloudwatch_log_metric_filter" "root_usage" {
  name           = "root-access-${var.environment}"
  pattern        = "{ $.userIdentity.type = Root }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name      = "RootAccountUsage"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

# CloudWatch Alarm for Root Account Usage
resource "aws_cloudwatch_metric_alarm" "root_usage" {
  alarm_name          = "root-access-alarm-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "RootAccountUsage"
  namespace          = "CloudTrailMetrics"
  period            = "300"
  statistic         = "Sum"
  threshold         = "0"
  alarm_description = "This metric monitors root account usage"
  alarm_actions     = [aws_sns_topic.cloudtrail.arn]

  tags = {
    Environment = var.environment
    Service     = "CloudTrail"
  }
}

# Data Source for Current Account ID
data "aws_caller_identity" "current" {} 