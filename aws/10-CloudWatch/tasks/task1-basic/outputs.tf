output "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alerts"
  value       = aws_sns_topic.alerts.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.application.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.application.arn
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
}

output "metric_alarms" {
  description = "Map of metric alarm names and their ARNs"
  value = {
    cpu_alarm    = aws_cloudwatch_metric_alarm.cpu_alarm.arn
    memory_alarm = aws_cloudwatch_metric_alarm.memory_alarm.arn
    disk_alarm   = aws_cloudwatch_metric_alarm.disk_alarm.arn
    error_alarm  = aws_cloudwatch_metric_alarm.error_alarm.arn
  }
}

output "metric_filter_name" {
  description = "Name of the error log metric filter"
  value       = aws_cloudwatch_log_metric_filter.error_logs.name
}

output "alert_subscription_arn" {
  description = "ARN of the SNS topic subscription"
  value       = aws_sns_topic_subscription.email.arn
} 