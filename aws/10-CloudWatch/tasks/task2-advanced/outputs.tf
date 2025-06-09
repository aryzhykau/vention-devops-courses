output "metric_stream_arn" {
  description = "ARN of the CloudWatch metric stream"
  value       = aws_cloudwatch_metric_stream.main.arn
}

output "firehose_arn" {
  description = "ARN of the Kinesis Firehose delivery stream"
  value       = aws_kinesis_firehose_delivery_stream.metrics.arn
}

output "metrics_bucket_name" {
  description = "Name of the S3 bucket storing metrics"
  value       = aws_s3_bucket.metrics.id
}

output "composite_alarm_arn" {
  description = "ARN of the composite alarm"
  value       = aws_cloudwatch_composite_alarm.service_health.arn
}

output "metric_alarms" {
  description = "Map of metric alarm names and their ARNs"
  value = {
    api_latency = aws_cloudwatch_metric_alarm.api_latency.arn
    error_rate  = aws_cloudwatch_metric_alarm.error_rate.arn
    cpu_usage   = aws_cloudwatch_metric_alarm.cpu_usage.arn
  }
}

output "monitoring_role_arn" {
  description = "ARN of the cross-account monitoring role"
  value       = aws_iam_role.monitoring.arn
}

output "dashboard_name" {
  description = "Name of the advanced monitoring dashboard"
  value       = aws_cloudwatch_dashboard.advanced.dashboard_name
}

output "dashboard_arn" {
  description = "ARN of the advanced monitoring dashboard"
  value       = aws_cloudwatch_dashboard.advanced.dashboard_arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
} 