# Common Variables
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name to be used in resource naming"
  type        = string
  default     = "demo"
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default = {
    Terraform = "true"
  }
}

# API Gateway Variables
variable "enable_api_gateway" {
  description = "Enable API Gateway integration"
  type        = bool
  default     = true
}

variable "api_gateway_type" {
  description = "Type of API Gateway (REST or HTTP)"
  type        = string
  default     = "REST"
}

variable "api_gateway_stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "dev"
}

variable "enable_api_gateway_logging" {
  description = "Enable API Gateway logging"
  type        = bool
  default     = true
}

variable "enable_api_gateway_cors" {
  description = "Enable CORS for API Gateway"
  type        = bool
  default     = true
}

# S3 Event Variables
variable "enable_s3_trigger" {
  description = "Enable S3 event trigger"
  type        = bool
  default     = true
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for event source"
  type        = string
}

variable "s3_event_types" {
  description = "List of S3 event types to trigger Lambda"
  type        = list(string)
  default     = ["s3:ObjectCreated:*"]
}

variable "s3_filter_prefix" {
  description = "Prefix filter for S3 events"
  type        = string
  default     = ""
}

variable "s3_filter_suffix" {
  description = "Suffix filter for S3 events"
  type        = string
  default     = ""
}

# EventBridge Variables
variable "enable_eventbridge" {
  description = "Enable EventBridge (CloudWatch Events) integration"
  type        = bool
  default     = true
}

variable "eventbridge_schedule" {
  description = "EventBridge schedule expression"
  type        = string
  default     = "rate(5 minutes)"
}

variable "eventbridge_event_pattern" {
  description = "EventBridge event pattern"
  type        = string
  default     = null
}

variable "enable_cross_account_events" {
  description = "Enable cross-account event routing"
  type        = bool
  default     = false
}

# SNS/SQS Variables
variable "enable_sns" {
  description = "Enable SNS integration"
  type        = bool
  default     = true
}

variable "enable_sqs" {
  description = "Enable SQS integration"
  type        = bool
  default     = true
}

variable "sqs_batch_size" {
  description = "Batch size for SQS event source"
  type        = number
  default     = 10
}

variable "enable_dlq" {
  description = "Enable Dead Letter Queue"
  type        = bool
  default     = true
}

variable "message_retention_seconds" {
  description = "Message retention period in seconds"
  type        = number
  default     = 345600  # 4 days
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout for SQS messages"
  type        = number
  default     = 30
}

# Lambda Function Variables
variable "lambda_runtime" {
  description = "Runtime for Lambda functions"
  type        = string
  default     = "python3.9"
}

variable "lambda_memory_size" {
  description = "Memory size for Lambda functions"
  type        = number
  default     = 128
}

variable "lambda_timeout" {
  description = "Timeout for Lambda functions"
  type        = number
  default     = 30
}

variable "lambda_log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "environment_variables" {
  description = "Environment variables for Lambda functions"
  type        = map(string)
  default     = {}
}

# Monitoring Variables
variable "enable_monitoring" {
  description = "Enable enhanced monitoring and alerting"
  type        = bool
  default     = true
}

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = ""
}

variable "error_rate_threshold" {
  description = "Error rate threshold for alarms"
  type        = number
  default     = 2
}

variable "latency_threshold" {
  description = "Latency threshold for alarms (milliseconds)"
  type        = number
  default     = 5000
} 