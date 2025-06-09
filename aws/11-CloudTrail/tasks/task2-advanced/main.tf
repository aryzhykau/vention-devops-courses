# Advanced CloudTrail Logging and Monitoring

# KMS Key for CloudTrail Encryption
resource "aws_kms_key" "cloudtrail" {
  description             = "KMS key for CloudTrail logs encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_policy.json

  tags = {
    Environment = var.environment
    Service     = "CloudTrail"
  }
}

# KMS Key Policy
data "aws_iam_policy_document" "kms_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudTrail to encrypt logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

# S3 Bucket for CloudTrail Logs with Advanced Configuration
resource "aws_s3_bucket" "advanced_trail" {
  bucket        = "cloudtrail-advanced-${var.environment}-${data.aws_caller_identity.current.account_id}"
  force_destroy = false

  tags = {
    Environment = var.environment
    Service     = "CloudTrail"
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "advanced_trail" {
  bucket = aws_s3_bucket.advanced_trail.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "advanced_trail" {
  bucket = aws_s3_bucket.advanced_trail.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cloudtrail.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# S3 Bucket Lifecycle Rules
resource "aws_s3_bucket_lifecycle_configuration" "advanced_trail" {
  bucket = aws_s3_bucket.advanced_trail.id

  rule {
    id     = "log-transition"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = var.log_retention_days
    }
  }
}

# Advanced CloudTrail with Data Events and Insights
resource "aws_cloudtrail" "advanced" {
  name                          = "advanced-trail-${var.environment}"
  s3_bucket_name               = aws_s3_bucket.advanced_trail.id
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_logging               = true
  kms_key_id                  = aws_kms_key.cloudtrail.arn
  enable_log_file_validation  = true

  # Data Events for S3
  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }

  # Data Events for Lambda
  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:*"]
    }
  }

  # Insights Events
  insight_selector {
    insight_type = "ApiCallRateInsight"
  }

  tags = {
    Environment = var.environment
    Service     = "CloudTrail"
  }
}

# Kinesis Firehose for CloudTrail Log Streaming
resource "aws_kinesis_firehose_delivery_stream" "cloudtrail" {
  name        = "cloudtrail-stream-${var.environment}"
  destination = "s3"

  s3_configuration {
    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = aws_s3_bucket.advanced_trail.arn
    prefix     = "firehose/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  }

  tags = {
    Environment = var.environment
    Service     = "CloudTrail"
  }
}

# IAM Role for Kinesis Firehose
resource "aws_iam_role" "firehose" {
  name = "cloudtrail-firehose-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Kinesis Firehose
resource "aws_iam_role_policy" "firehose" {
  name = "cloudtrail-firehose-policy"
  role = aws_iam_role.firehose.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.advanced_trail.arn,
          "${aws_s3_bucket.advanced_trail.arn}/*"
        ]
      }
    ]
  })
}

# CloudWatch Log Group for Advanced Monitoring
resource "aws_cloudwatch_log_group" "advanced_trail" {
  name              = "/aws/cloudtrail/advanced-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    Service     = "CloudTrail"
  }
}

# CloudWatch Metric Filter for API Activity
resource "aws_cloudwatch_log_metric_filter" "api_activity" {
  name           = "api-activity-${var.environment}"
  pattern        = "[$.eventName, $.eventSource, $.sourceIPAddress]"
  log_group_name = aws_cloudwatch_log_group.advanced_trail.name

  metric_transformation {
    name      = "ApiActivity"
    namespace = "CloudTrailMetrics"
    value     = "1"
    dimensions = {
      EventSource = "$.eventSource"
      EventName   = "$.eventName"
    }
  }
}

# CloudWatch Dashboard for CloudTrail Monitoring
resource "aws_cloudwatch_dashboard" "cloudtrail" {
  dashboard_name = "cloudtrail-monitoring-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["CloudTrailMetrics", "ApiActivity", "EventSource", "iam.amazonaws.com"],
            ["CloudTrailMetrics", "ApiActivity", "EventSource", "s3.amazonaws.com"],
            ["CloudTrailMetrics", "ApiActivity", "EventSource", "lambda.amazonaws.com"]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "API Activity by Service"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/CloudTrail", "Events", "Trail", aws_cloudtrail.advanced.name],
            ["AWS/CloudTrail", "EventsBucket", "Trail", aws_cloudtrail.advanced.name]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "CloudTrail Events"
        }
      }
    ]
  })
}

# Data Source for Current Account ID
data "aws_caller_identity" "current" {} 