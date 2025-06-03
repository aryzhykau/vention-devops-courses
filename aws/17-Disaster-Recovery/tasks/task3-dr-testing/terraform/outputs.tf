output "dr_docs_bucket" {
  description = "Name of the S3 bucket for DR documentation"
  value       = aws_s3_bucket.dr_docs.id
}

output "lambda_function_name" {
  description = "Name of the backup validator Lambda function"
  value       = aws_lambda_function.backup_validator.function_name
}

output "lambda_function_arn" {
  description = "ARN of the backup validator Lambda function"
  value       = aws_lambda_function.backup_validator.arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for DR notifications"
  value       = aws_sns_topic.dr_notifications.arn
}

output "cloudwatch_log_group" {
  description = "Name of the CloudWatch Log Group for Lambda logs"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule for DR testing"
  value       = aws_cloudwatch_event_rule.dr_test.arn
} 