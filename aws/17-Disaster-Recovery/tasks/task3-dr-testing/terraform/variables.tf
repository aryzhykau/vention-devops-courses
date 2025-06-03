variable "aws_region" {
  description = "AWS region for the resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "dr-demo"
}

variable "backup_vault_name" {
  description = "Name of the AWS Backup vault to monitor"
  type        = string
  default     = "dr-demo-vault"
}

variable "test_schedule" {
  description = "Schedule expression for DR tests"
  type        = string
  default     = "rate(1 day)" # Run daily
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7 # Free tier friendly retention period
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "DR-Demo"
    Terraform   = "true"
  }
} 