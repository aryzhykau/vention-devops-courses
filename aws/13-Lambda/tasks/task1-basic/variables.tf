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

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "basic-lambda"
}

variable "runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "python3.9"
}

variable "handler" {
  description = "Handler function name"
  type        = string
  default     = "handler.handler"
}

variable "memory_size" {
  description = "Memory size for the Lambda function in MB"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 30
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 14
}

variable "enable_xray" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = false
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default = {
    Terraform = "true"
  }
}

variable "enable_cloudwatch_alerts" {
  description = "Enable CloudWatch alerts for the Lambda function"
  type        = bool
  default     = true
}

variable "error_rate_threshold" {
  description = "Error rate threshold for CloudWatch alarm (percentage)"
  type        = number
  default     = 2
}

variable "duration_threshold" {
  description = "Duration threshold for CloudWatch alarm (milliseconds)"
  type        = number
  default     = 10000  # 10 seconds
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alerts"
  type        = string
  default     = ""
}

variable "reserved_concurrent_executions" {
  description = "Reserved concurrent executions for the Lambda function (-1 for unlimited)"
  type        = number
  default     = -1
}

variable "enable_function_url" {
  description = "Enable Lambda function URL"
  type        = bool
  default     = false
}

variable "function_url_auth_type" {
  description = "Authentication type for function URL (NONE or AWS_IAM)"
  type        = string
  default     = "AWS_IAM"
}

variable "enable_provisioned_concurrency" {
  description = "Enable provisioned concurrency"
  type        = bool
  default     = false
}

variable "provisioned_concurrent_executions" {
  description = "Number of provisioned concurrent executions"
  type        = number
  default     = 0
} 