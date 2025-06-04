# DynamoDB Table Outputs
output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.main.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.main.arn
}

output "table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.main.id
}

output "table_hash_key" {
  description = "Hash key of the table"
  value       = aws_dynamodb_table.main.hash_key
}

output "table_billing_mode" {
  description = "Billing mode of the table"
  value       = aws_dynamodb_table.main.billing_mode
}

# Capacity Outputs
output "read_capacity" {
  description = "Read capacity units of the table"
  value       = var.billing_mode == "PROVISIONED" ? aws_dynamodb_table.main.read_capacity : "N/A (On-Demand)"
}

output "write_capacity" {
  description = "Write capacity units of the table"
  value       = var.billing_mode == "PROVISIONED" ? aws_dynamodb_table.main.write_capacity : "N/A (On-Demand)"
}

# Auto Scaling Outputs
output "autoscaling_read_target" {
  description = "Read capacity auto scaling target"
  value       = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? {
    min_capacity = aws_appautoscaling_target.read_target[0].min_capacity
    max_capacity = aws_appautoscaling_target.read_target[0].max_capacity
  } : null
}

output "autoscaling_write_target" {
  description = "Write capacity auto scaling target"
  value       = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? {
    min_capacity = aws_appautoscaling_target.write_target[0].min_capacity
    max_capacity = aws_appautoscaling_target.write_target[0].max_capacity
  } : null
}

# Monitoring Outputs
output "cloudwatch_alarms" {
  description = "CloudWatch alarms for the table"
  value       = var.enable_monitoring ? {
    read_throttle_alarm  = aws_cloudwatch_metric_alarm.read_throttle[0].arn
    write_throttle_alarm = aws_cloudwatch_metric_alarm.write_throttle[0].arn
  } : null
}

output "sns_topic" {
  description = "SNS topic for alerts"
  value       = var.enable_monitoring && var.alert_email != "" ? {
    arn     = aws_sns_topic.alerts[0].arn
    name    = aws_sns_topic.alerts[0].name
    email   = var.alert_email
  } : null
}

# Lambda Integration Outputs
output "lambda_function" {
  description = "Lambda function details"
  value       = var.enable_lambda_trigger ? {
    function_name = aws_lambda_function.dynamodb_trigger[0].function_name
    function_arn  = aws_lambda_function.dynamodb_trigger[0].arn
    role_arn     = aws_lambda_function.dynamodb_trigger[0].role
  } : null
}

# Table Features
output "table_features" {
  description = "Enabled features for the table"
  value = {
    point_in_time_recovery = var.enable_point_in_time_recovery
    server_side_encryption = var.enable_server_side_encryption
    ttl_enabled           = var.enable_ttl
    ttl_attribute         = var.enable_ttl ? var.ttl_attribute : null
    autoscaling_enabled   = var.enable_autoscaling
    monitoring_enabled    = var.enable_monitoring
    lambda_trigger        = var.enable_lambda_trigger
  }
}

# Stream Details
output "stream_details" {
  description = "DynamoDB stream details"
  value       = var.enable_lambda_trigger ? {
    stream_enabled = aws_dynamodb_table.main.stream_enabled
    stream_arn    = aws_dynamodb_table.main.stream_arn
    stream_label  = aws_dynamodb_table.main.stream_label
  } : null
} 