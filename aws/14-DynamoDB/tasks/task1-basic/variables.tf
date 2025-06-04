# Common Variables
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name to be used in resource naming"
  type        = string
  default     = "dynamodb-demo"
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default = {
    Terraform = "true"
  }
}

# DynamoDB Table Variables
variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "Users"
}

variable "billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "read_capacity" {
  description = "Read capacity units for the table (required if PROVISIONED)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units for the table (required if PROVISIONED)"
  type        = number
  default     = 5
}

# Auto Scaling Variables
variable "enable_autoscaling" {
  description = "Enable DynamoDB auto scaling"
  type        = bool
  default     = false
}

variable "min_read_capacity" {
  description = "Minimum read capacity for auto scaling"
  type        = number
  default     = 5
}

variable "max_read_capacity" {
  description = "Maximum read capacity for auto scaling"
  type        = number
  default     = 100
}

variable "min_write_capacity" {
  description = "Minimum write capacity for auto scaling"
  type        = number
  default     = 5
}

variable "max_write_capacity" {
  description = "Maximum write capacity for auto scaling"
  type        = number
  default     = 100
}

variable "target_utilization" {
  description = "Target utilization percentage for auto scaling"
  type        = number
  default     = 70
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

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "enable_server_side_encryption" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

# TTL Configuration
variable "enable_ttl" {
  description = "Enable Time to Live (TTL)"
  type        = bool
  default     = false
}

variable "ttl_attribute" {
  description = "TTL attribute name"
  type        = string
  default     = "ExpirationTime"
}

# Lambda Integration
variable "enable_lambda_trigger" {
  description = "Enable Lambda function trigger"
  type        = bool
  default     = false
}

variable "lambda_function_name" {
  description = "Name of the Lambda function to trigger"
  type        = string
  default     = "dynamodb-handler"
} 