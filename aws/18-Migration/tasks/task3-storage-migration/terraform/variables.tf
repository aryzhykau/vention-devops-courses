variable "aws_region" {
  description = "AWS region for the resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "migration-demo"
}

variable "availability_zone" {
  description = "Availability zone for EBS volume"
  type        = string
  default     = "us-east-1a"
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7 # Free tier friendly retention period
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7 # Free tier friendly retention period
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "Migration-Demo"
    Terraform   = "true"
  }
} 