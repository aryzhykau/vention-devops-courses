# Basic CloudWatch Setup

# SNS Topic for Alarms
resource "aws_sns_topic" "alerts" {
  name = "cloudwatch-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/application/${var.environment}"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    Application = var.application_name
  }
}

# CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period            = "300"
  statistic         = "Average"
  threshold         = var.cpu_threshold
  
  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_description = "This metric monitors EC2 CPU utilization"
  alarm_actions     = [aws_sns_topic.alerts.arn]
}

# Memory Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "memory_alarm" {
  alarm_name          = "high-memory-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "MemoryUtilization"
  namespace          = "System/Linux"
  period            = "300"
  statistic         = "Average"
  threshold         = var.memory_threshold
  
  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_description = "This metric monitors EC2 memory utilization"
  alarm_actions     = [aws_sns_topic.alerts.arn]
}

# Disk Space Alarm
resource "aws_cloudwatch_metric_alarm" "disk_alarm" {
  alarm_name          = "high-disk-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "DiskSpaceUtilization"
  namespace          = "System/Linux"
  period            = "300"
  statistic         = "Average"
  threshold         = var.disk_threshold
  
  dimensions = {
    AutoScalingGroupName = var.asg_name
    Filesystem          = "/dev/xvda1"
    MountPath          = "/"
  }

  alarm_description = "This metric monitors EC2 disk space utilization"
  alarm_actions     = [aws_sns_topic.alerts.arn]
}

# Error Log Metric Filter
resource "aws_cloudwatch_log_metric_filter" "error_logs" {
  name           = "error-logs"
  pattern        = "ERROR"
  log_group_name = aws_cloudwatch_log_group.application.name

  metric_transformation {
    name          = "ErrorCount"
    namespace     = "Custom/Application"
    value         = "1"
    default_value = "0"
  }
}

# Error Count Alarm
resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  alarm_name          = "high-error-count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "ErrorCount"
  namespace          = "Custom/Application"
  period            = "300"
  statistic         = "Sum"
  threshold         = var.error_threshold
  
  alarm_description = "This metric monitors application error count"
  alarm_actions     = [aws_sns_topic.alerts.arn]
}

# Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.environment}-dashboard"
  
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
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name],
            ["System/Linux", "MemoryUtilization", "AutoScalingGroupName", var.asg_name],
            ["System/Linux", "DiskSpaceUtilization", "AutoScalingGroupName", var.asg_name, "Filesystem", "/dev/xvda1", "MountPath", "/"]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Resource Utilization"
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
            ["Custom/Application", "ErrorCount"]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Application Errors"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          query   = "fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 20"
          region  = var.aws_region
          title   = "Error Logs"
          view    = "table"
        }
      }
    ]
  })
} 