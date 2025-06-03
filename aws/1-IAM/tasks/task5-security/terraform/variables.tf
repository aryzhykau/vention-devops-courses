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

variable "max_key_age_days" {
  description = "Maximum age in days for IAM access keys before rotation is required"
  type        = number
  default     = 90
}

variable "cloudtrail_retention_days" {
  description = "Number of days to retain CloudTrail logs"
  type        = number
  default     = 365
}

variable "config_retention_days" {
  description = "Number of days to retain AWS Config data"
  type        = number
  default     = 365
}

variable "notification_email" {
  description = "Email address for security notifications"
  type        = string
}

variable "enable_mfa_enforcement" {
  description = "Whether to enforce MFA for all IAM users"
  type        = bool
  default     = true
}

variable "enable_access_analyzer" {
  description = "Whether to enable IAM Access Analyzer"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
  }
} 