# API Gateway Outputs
output "api_gateway_url" {
  description = "URL of the API Gateway endpoint"
  value       = var.enable_api_gateway ? aws_api_gateway_stage.main[0].invoke_url : null
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = var.enable_api_gateway ? aws_api_gateway_rest_api.main[0].id : null
}

output "api_gateway_stage" {
  description = "Stage information of the API Gateway"
  value       = var.enable_api_gateway ? aws_api_gateway_stage.main[0].stage_name : null
}

# S3 Event Outputs
output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = var.enable_s3_trigger ? aws_s3_bucket.event_source[0].arn : null
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = var.enable_s3_trigger ? aws_s3_bucket.event_source[0].id : null
}

output "s3_notification_configuration" {
  description = "S3 notification configuration"
  value       = var.enable_s3_trigger ? aws_s3_bucket_notification.bucket_notification[0].lambda_function : null
}

# EventBridge Outputs
output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule"
  value       = var.enable_eventbridge ? aws_cloudwatch_event_rule.main[0].arn : null
}

output "eventbridge_rule_id" {
  description = "ID of the EventBridge rule"
  value       = var.enable_eventbridge ? aws_cloudwatch_event_rule.main[0].id : null
}

output "eventbridge_target_id" {
  description = "ID of the EventBridge target"
  value       = var.enable_eventbridge ? aws_cloudwatch_event_target.lambda[0].id : null
}

# SNS Outputs
output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = var.enable_sns ? aws_sns_topic.main[0].arn : null
}

output "sns_topic_name" {
  description = "Name of the SNS topic"
  value       = var.enable_sns ? aws_sns_topic.main[0].name : null
}

# SQS Outputs
output "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  value       = var.enable_sqs ? aws_sqs_queue.main[0].arn : null
}

output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = var.enable_sqs ? aws_sqs_queue.main[0].url : null
}

output "sqs_dlq_arn" {
  description = "ARN of the Dead Letter Queue"
  value       = var.enable_dlq ? aws_sqs_queue.dlq[0].arn : null
}

output "sqs_dlq_url" {
  description = "URL of the Dead Letter Queue"
  value       = var.enable_dlq ? aws_sqs_queue.dlq[0].url : null
}

# Lambda Function Outputs
output "lambda_functions" {
  description = "Map of Lambda functions and their configurations"
  value = {
    api = var.enable_api_gateway ? {
      arn           = aws_lambda_function.api[0].arn
      function_name = aws_lambda_function.api[0].function_name
      invoke_arn    = aws_lambda_function.api[0].invoke_arn
    } : null
    s3 = var.enable_s3_trigger ? {
      arn           = aws_lambda_function.s3[0].arn
      function_name = aws_lambda_function.s3[0].function_name
      invoke_arn    = aws_lambda_function.s3[0].invoke_arn
    } : null
    events = var.enable_eventbridge ? {
      arn           = aws_lambda_function.events[0].arn
      function_name = aws_lambda_function.events[0].function_name
      invoke_arn    = aws_lambda_function.events[0].invoke_arn
    } : null
    queue = var.enable_sqs ? {
      arn           = aws_lambda_function.queue[0].arn
      function_name = aws_lambda_function.queue[0].function_name
      invoke_arn    = aws_lambda_function.queue[0].invoke_arn
    } : null
  }
}

# IAM Role Outputs
output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_role_name" {
  description = "Name of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.name
}

# Monitoring Outputs
output "cloudwatch_log_groups" {
  description = "Map of CloudWatch Log Groups"
  value = {
    api    = var.enable_api_gateway ? aws_cloudwatch_log_group.api[0].name : null
    s3     = var.enable_s3_trigger ? aws_cloudwatch_log_group.s3[0].name : null
    events = var.enable_eventbridge ? aws_cloudwatch_log_group.events[0].name : null
    queue  = var.enable_sqs ? aws_cloudwatch_log_group.queue[0].name : null
  }
}

output "alarm_arns" {
  description = "Map of CloudWatch Alarm ARNs"
  value = var.enable_monitoring ? {
    api_errors    = aws_cloudwatch_metric_alarm.api_errors[0].arn
    s3_errors     = aws_cloudwatch_metric_alarm.s3_errors[0].arn
    events_errors = aws_cloudwatch_metric_alarm.events_errors[0].arn
    queue_errors  = aws_cloudwatch_metric_alarm.queue_errors[0].arn
    api_latency   = aws_cloudwatch_metric_alarm.api_latency[0].arn
  } : null
} 