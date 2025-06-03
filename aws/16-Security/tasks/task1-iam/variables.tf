variable "project_name" {
  description = "Name of the project, used as prefix for all resources"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

# IAM User Variables
variable "iam_users" {
  description = "List of IAM users to create"
  type = list(object({
    username = string
    groups   = list(string)
    tags     = map(string)
  }))
  default = []
}

# IAM Group Variables
variable "iam_groups" {
  description = "List of IAM groups to create"
  type = list(object({
    name        = string
    path        = string
    policies    = list(string)
    description = string
  }))
  default = []
}

# Password Policy Variables
variable "password_policy" {
  description = "Password policy settings"
  type = object({
    minimum_password_length        = number
    require_lowercase             = bool
    require_uppercase             = bool
    require_numbers               = bool
    require_symbols               = bool
    allow_users_to_change_password = bool
    max_password_age              = number
    password_reuse_prevention     = number
  })
  default = {
    minimum_password_length        = 12
    require_lowercase             = true
    require_uppercase             = true
    require_numbers               = true
    require_symbols               = true
    allow_users_to_change_password = true
    max_password_age              = 90
    password_reuse_prevention     = 24
  }
}

# MFA Configuration
variable "require_mfa" {
  description = "Whether to require MFA for IAM users"
  type        = bool
  default     = true
}

# Access Key Configuration
variable "access_key_rotation_days" {
  description = "Number of days after which access keys should be rotated"
  type        = number
  default     = 90
}

# CloudWatch Logging
variable "enable_cloudwatch_logging" {
  description = "Enable CloudWatch logging for IAM events"
  type        = bool
  default     = true
}

# Tags
variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {
    Environment = "development"
    ManagedBy   = "terraform"
  }
} 