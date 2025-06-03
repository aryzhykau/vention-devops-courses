# S3 Bucket for Event Source
resource "aws_s3_bucket" "event_source" {
  count = var.enable_s3_trigger ? 1 : 0

  bucket = "${var.project_name}-${var.environment}-${var.s3_bucket_name}"

  tags = merge(var.tags, {
    Name        = "${var.project_name}-s3"
    Environment = var.environment
  })
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "event_source" {
  count = var.enable_s3_trigger ? 1 : 0

  bucket = aws_s3_bucket.event_source[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "event_source" {
  count = var.enable_s3_trigger ? 1 : 0

  bucket = aws_s3_bucket.event_source[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "event_source" {
  count = var.enable_s3_trigger ? 1 : 0

  bucket = aws_s3_bucket.event_source[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Rules
resource "aws_s3_bucket_lifecycle_configuration" "event_source" {
  count = var.enable_s3_trigger ? 1 : 0

  bucket = aws_s3_bucket.event_source[0].id

  rule {
    id     = "cleanup"
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
resource "aws_s3_bucket_policy" "event_source" {
  count = var.enable_s3_trigger ? 1 : 0

  bucket = aws_s3_bucket.event_source[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.event_source[0].arn,
          "${aws_s3_bucket.event_source[0].arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# S3 Event Notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  count = var.enable_s3_trigger ? 1 : 0

  bucket = aws_s3_bucket.event_source[0].id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3[0].arn
    events              = var.s3_event_types
    filter_prefix       = var.s3_filter_prefix
    filter_suffix       = var.s3_filter_suffix
  }

  depends_on = [aws_lambda_permission.s3]
}

# CloudWatch Log Group for S3 Events
resource "aws_cloudwatch_log_group" "s3" {
  count = var.enable_s3_trigger ? 1 : 0

  name              = "/aws/lambda/${var.project_name}-${var.environment}-s3"
  retention_in_days = var.lambda_log_retention_days

  tags = merge(var.tags, {
    Name        = "${var.project_name}-s3-logs"
    Environment = var.environment
  })
}

# CloudWatch Metric Alarm for S3 Events
resource "aws_cloudwatch_metric_alarm" "s3_errors" {
  count = var.enable_s3_trigger && var.enable_monitoring ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-s3-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "Errors"
  namespace          = "AWS/Lambda"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.error_rate_threshold
  alarm_description  = "This metric monitors S3 event processing errors"

  dimensions = {
    FunctionName = aws_lambda_function.s3[0].function_name
  }

  alarm_actions = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions    = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []

  tags = merge(var.tags, {
    Name        = "${var.project_name}-s3-alarm"
    Environment = var.environment
  })
} 