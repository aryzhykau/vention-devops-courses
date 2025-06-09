variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name to be used as prefix for all resources"
  type        = string
  default     = "demo"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "source_account_id" {
  description = "AWS account ID of the source account"
  type        = string
}

variable "external_id" {
  description = "External ID for cross-account role assumption"
  type        = string
}

variable "target_bucket" {
  description = "Name of the S3 bucket in target account"
  type        = string
}

variable "cloudtrail_bucket" {
  description = "Name of the S3 bucket for CloudTrail logs"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
  }
} 