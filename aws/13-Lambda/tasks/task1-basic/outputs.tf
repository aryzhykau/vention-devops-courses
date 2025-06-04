output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.main.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.main.arn
}

output "function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.main.invoke_arn
}

output "function_version" {
  description = "Latest published version of the Lambda function"
  value       = aws_lambda_function.main.version
}

output "function_last_modified" {
  description = "Date Lambda function was last modified"
  value       = aws_lambda_function.main.last_modified
}

output "function_role_arn" {
  description = "ARN of the IAM role used by the Lambda function"
  value       = aws_iam_role.lambda_role.arn
}

output "function_role_name" {
  description = "Name of the IAM role used by the Lambda function"
  value       = aws_iam_role.lambda_role.name
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for the Lambda function"
  value       = aws_cloudwatch_log_group.lambda.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for the Lambda function"
  value       = aws_cloudwatch_log_group.lambda.arn
}

output "function_url" {
  description = "URL of the Lambda function (if enabled)"
  value       = var.enable_function_url ? aws_lambda_function_url.main[0].url : null
}

output "function_qualified_arn" {
  description = "ARN identifying your Lambda function version"
  value       = aws_lambda_function.main.qualified_arn
}

output "function_qualified_invoke_arn" {
  description = "Qualified ARN for invoking Lambda function version"
  value       = aws_lambda_function.main.qualified_invoke_arn
}

output "cloudwatch_alarm_arns" {
  description = "ARNs of CloudWatch alarms"
  value = var.enable_cloudwatch_alerts ? {
    error_rate = aws_cloudwatch_metric_alarm.error_rate[0].arn
    duration   = aws_cloudwatch_metric_alarm.duration[0].arn
  } : null
}

output "provisioned_concurrency_config" {
  description = "Provisioned concurrency configuration (if enabled)"
  value = var.enable_provisioned_concurrency ? {
    version    = aws_lambda_function.main.version
    amount     = var.provisioned_concurrent_executions
    qualifier  = aws_lambda_alias.provisioned[0].name
  } : null
}

output "function_tags" {
  description = "Tags applied to the Lambda function"
  value       = aws_lambda_function.main.tags
} 