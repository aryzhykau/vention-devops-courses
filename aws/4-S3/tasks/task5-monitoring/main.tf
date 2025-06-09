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

# Create S3 bucket
resource "aws_s3_bucket" "main" {
  bucket = "monitored-bucket-${random_string.suffix.result}"

  tags = {
    Name        = "MonitoredBucket"
    Environment = "Training"
    Project     = "AWS-Course"
  }
}

# Enable transfer acceleration
resource "aws_s3_bucket_accelerate_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  status = "Enabled"
}

# Enable versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  
  versioning_configuration {
    status = "Enabled"
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

# Create SNS topic for alerts
resource "aws_sns_topic" "monitoring" {
  name = "s3-monitoring-${random_string.suffix.result}"
}

# Create CloudWatch dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "s3-monitoring-dashboard"

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
            ["AWS/S3", "NumberOfObjects", "BucketName", aws_s3_bucket.main.id],
            [".", "BucketSizeBytes", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = "us-west-2"
          title  = "Bucket Size and Object Count"
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
            ["AWS/S3", "FirstByteLatency", "BucketName", aws_s3_bucket.main.id],
            [".", "TotalRequestLatency", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = "us-west-2"
          title  = "Latency Metrics"
        }
      }
    ]
  })
}

# Create CloudWatch alarms
resource "aws_cloudwatch_metric_alarm" "error_rate" {
  alarm_name          = "s3-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "5xxErrors"
  namespace           = "AWS/S3"
  period             = "300"
  statistic          = "Average"
  threshold          = "5"
  alarm_description  = "This metric monitors S3 error rates"
  alarm_actions      = [aws_sns_topic.monitoring.arn]

  dimensions = {
    BucketName = aws_s3_bucket.main.id
  }
}

resource "aws_cloudwatch_metric_alarm" "latency" {
  alarm_name          = "s3-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FirstByteLatency"
  namespace           = "AWS/S3"
  period             = "300"
  statistic          = "Average"
  threshold          = "1000"
  alarm_description  = "This metric monitors S3 latency"
  alarm_actions      = [aws_sns_topic.monitoring.arn]

  dimensions = {
    BucketName = aws_s3_bucket.main.id
  }
}

# Create S3 Storage Lens configuration
resource "aws_s3control_storage_lens_configuration" "main" {
  config_id = "example-storage-lens"
  
  storage_lens_configuration {
    enabled = true

    account_level {
      activity_metrics {
        enabled = true
      }
      bucket_level {
        activity_metrics {
          enabled = true
        }
        prefix_level {
          storage_metrics {
            enabled = true
            selection_criteria {
              delimiter                     = "/"
              max_depth                     = 5
              min_storage_bytes_percentage = 1.0
            }
          }
        }
      }
    }

    data_export {
      s3_bucket_destination {
        account_id            = data.aws_caller_identity.current.account_id
        arn                   = aws_s3_bucket.logs.arn
        format               = "CSV"
        output_schema_version = "V_1"
        prefix               = "storage-lens/"
      }
    }
  }
}

# Create budget for cost monitoring
resource "aws_budgets_budget" "s3" {
  name              = "s3-monthly-budget"
  budget_type       = "COST"
  limit_amount      = "50"
  limit_unit        = "USD"
  time_period_start = "2024-01-01_00:00"
  time_unit         = "MONTHLY"

  cost_filter {
    name = "Service"
    values = ["Amazon Simple Storage Service"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = ["your-email@example.com"]
  }
}

# Create metric filter for access patterns
resource "aws_cloudwatch_log_metric_filter" "access_pattern" {
  name           = "s3-access-pattern"
  pattern        = "[timestamp, bucket, operation, key]"
  log_group_name = "/aws/s3/access-logs"

  metric_transformation {
    name          = "S3AccessCount"
    namespace     = "CustomS3Metrics"
    value         = "1"
    default_value = "0"
  }
}

# Data sources
data "aws_caller_identity" "current" {}

# Outputs
output "bucket_name" {
  description = "Name of the monitored bucket"
  value       = aws_s3_bucket.main.id
}

output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "storage_lens_config_id" {
  description = "ID of the Storage Lens configuration"
  value       = aws_s3control_storage_lens_configuration.main.config_id
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.monitoring.arn
}

# Data source for current region
data "aws_region" "current" {} 