output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.main.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.main.name
}

output "queue1_url" {
  description = "URL of the first SQS queue"
  value       = aws_sqs_queue.queue1.url
}

output "queue1_arn" {
  description = "ARN of the first SQS queue"
  value       = aws_sqs_queue.queue1.arn
}

output "queue2_url" {
  description = "URL of the second SQS queue"
  value       = aws_sqs_queue.queue2.url
}

output "queue2_arn" {
  description = "ARN of the second SQS queue"
  value       = aws_sqs_queue.queue2.arn
}

output "dlq1_url" {
  description = "URL of the first queue's DLQ"
  value       = var.enable_dlq ? aws_sqs_queue.dlq1[0].url : null
}

output "dlq2_url" {
  description = "URL of the second queue's DLQ"
  value       = var.enable_dlq ? aws_sqs_queue.dlq2[0].url : null
}

output "cloudwatch_alarm_arns" {
  description = "ARNs of CloudWatch alarms"
  value = var.enable_cloudwatch_alerts ? {
    queue1_depth = aws_cloudwatch_metric_alarm.queue1_depth[0].arn
    queue2_depth = aws_cloudwatch_metric_alarm.queue2_depth[0].arn
    dlq1_depth   = var.enable_dlq ? aws_cloudwatch_metric_alarm.dlq1_depth[0].arn : null
    dlq2_depth   = var.enable_dlq ? aws_cloudwatch_metric_alarm.dlq2_depth[0].arn : null
  } : null
}

output "sns_topic_subscription_arns" {
  description = "ARNs of SNS topic subscriptions"
  value = {
    queue1 = aws_sns_topic_subscription.queue1.arn
    queue2 = aws_sns_topic_subscription.queue2.arn
  }
} 