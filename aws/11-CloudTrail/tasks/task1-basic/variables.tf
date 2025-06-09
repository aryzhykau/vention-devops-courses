variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (e.g., production, staging)"
  type        = string
  default     = "production"
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "enable_log_file_validation" {
  description = "Enables log file integrity validation"
  type        = bool
  default     = true
}

variable "include_global_service_events" {
  description = "Specifies whether the trail is publishing events from global services"
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "Specifies whether the trail is created in the current region or in all regions"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enables logging for the trail"
  type        = bool
  default     = true
}

variable "allow_s3_force_destroy" {
  description = "Allow the S3 bucket to be destroyed even if it contains objects"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "notification_email" {
  description = "Email address to receive CloudTrail notifications"
  type        = string
  default     = ""
}

variable "metric_namespace" {
  description = "Namespace for CloudWatch metrics"
  type        = string
  default     = "CloudTrailMetrics"
}

variable "enable_root_access_alerts" {
  description = "Enable alerts for root account usage"
  type        = bool
  default     = true
}

variable "root_access_evaluation_periods" {
  description = "Number of periods to evaluate for root access alerts"
  type        = number
  default     = 1
}

variable "root_access_period" {
  description = "Period in seconds for root access evaluation"
  type        = number
  default     = 300
} 