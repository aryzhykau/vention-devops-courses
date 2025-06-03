# Advanced CloudWatch Monitoring

# Custom Metric Namespace
resource "aws_cloudwatch_metric_stream" "main" {
  name          = "advanced-metrics-stream"
  firehose_arn  = aws_kinesis_firehose_delivery_stream.metrics.arn
  output_format = "json"

  include_filter {
    namespace = "AWS/EC2"
  }

  include_filter {
    namespace = "AWS/RDS"
  }

  include_filter {
    namespace = "AWS/Lambda"
  }

  role_arn = aws_iam_role.metric_stream.arn
}

# Kinesis Firehose for Metric Streaming
resource "aws_kinesis_firehose_delivery_stream" "metrics" {
  name        = "cloudwatch-metrics-stream"
  destination = "s3"

  s3_configuration {
    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = aws_s3_bucket.metrics.arn
    prefix     = "metrics/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  }
}

# S3 Bucket for Metric Storage
resource "aws_s3_bucket" "metrics" {
  bucket = "advanced-metrics-${var.environment}-${data.aws_caller_identity.current.account_id}"
}

# Composite Alarm
resource "aws_cloudwatch_composite_alarm" "service_health" {
  alarm_name = "service-health"
  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.api_latency.alarm_name}) OR (ALARM(${aws_cloudwatch_metric_alarm.error_rate.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.cpu_usage.alarm_name}))"

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# API Latency Alarm with Anomaly Detection
resource "aws_cloudwatch_metric_alarm" "api_latency" {
  alarm_name          = "api-latency-anomaly"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = "3"
  threshold_metric_id = "e1"
  
  metric_query {
    id          = "m1"
    return_data = true
    metric {
      metric_name = "Latency"
      namespace   = "AWS/ApiGateway"
      period     = "300"
      stat       = "Average"
      dimensions = {
        ApiName = var.api_name
      }
    }
  }

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    label       = "Latency (Expected)"
    return_data = true
  }
}

# Error Rate Alarm with Metric Math
resource "aws_cloudwatch_metric_alarm" "error_rate" {
  alarm_name          = "error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  threshold          = "5"
  
  metric_query {
    id          = "e1"
    expression  = "m2/m1*100"
    label       = "Error Rate"
    return_data = true
  }
  
  metric_query {
    id = "m1"
    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/ApiGateway"
      period     = "300"
      stat       = "Sum"
      dimensions = {
        ApiName = var.api_name
      }
    }
  }
  
  metric_query {
    id = "m2"
    metric {
      metric_name = "5XXError"
      namespace   = "AWS/ApiGateway"
      period     = "300"
      stat       = "Sum"
      dimensions = {
        ApiName = var.api_name
      }
    }
  }
}

# CPU Usage Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_usage" {
  alarm_name          = "high-cpu-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period            = "300"
  statistic         = "Average"
  threshold         = "80"
  
  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
}

# Cross-Account Role
resource "aws_iam_role" "monitoring" {
  name = "cross-account-monitoring"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.monitoring_account_id}:root"
        }
      }
    ]
  })
}

# Cross-Account Policy
resource "aws_iam_role_policy" "monitoring" {
  name = "cross-account-monitoring-policy"
  role = aws_iam_role.monitoring.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:GetMetricStream",
          "cloudwatch:DescribeAlarms"
        ]
        Resource = "*"
      }
    ]
  })
}

# Advanced Dashboard
resource "aws_cloudwatch_dashboard" "advanced" {
  dashboard_name = "advanced-monitoring"
  
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
            ["AWS/ApiGateway", "Latency", "ApiName", var.api_name],
            [{
              expression = "ANOMALY_DETECTION_BAND(m1, 2)",
              label = "Expected Latency Range",
              id = "e1"
            }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "API Latency with Anomaly Detection"
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
            [{
              expression = "m2/m1*100",
              label = "Error Rate (%)",
              id = "e1"
            }],
            ["AWS/ApiGateway", "RequestCount", "ApiName", var.api_name, { id = "m1", visible = false }],
            ["AWS/ApiGateway", "5XXError", "ApiName", var.api_name, { id = "m2", visible = false }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "API Error Rate"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name],
            [{
              expression = "ANOMALY_DETECTION_BAND(m1, 2)",
              label = "Expected CPU Range",
              id = "e1"
            }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "CPU Utilization with Anomaly Detection"
        }
      }
    ]
  })
}

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "advanced-monitoring-alerts"
}

# Data Source for Current Account ID
data "aws_caller_identity" "current" {} 