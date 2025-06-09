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

variable "api_name" {
  description = "Name of the API Gateway to monitor"
  type        = string
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group to monitor"
  type        = string
}

variable "monitoring_account_id" {
  description = "AWS account ID for cross-account monitoring"
  type        = string
}

variable "metric_stream_include_filters" {
  description = "List of namespaces to include in metric stream"
  type        = list(string)
  default     = ["AWS/EC2", "AWS/RDS", "AWS/Lambda"]
}

variable "anomaly_detection_threshold" {
  description = "Number of standard deviations for anomaly detection"
  type        = number
  default     = 2
}

variable "error_rate_threshold" {
  description = "Threshold percentage for error rate alarm"
  type        = number
  default     = 5
}

variable "evaluation_periods" {
  description = "Number of periods to evaluate for alarms"
  type        = number
  default     = 2
}

variable "metric_period" {
  description = "Period in seconds for metric aggregation"
  type        = number
  default     = 300
}

variable "cpu_threshold" {
  description = "CPU utilization threshold percentage for alarm"
  type        = number
  default     = 80
}

variable "metric_retention_days" {
  description = "Number of days to retain metrics in S3"
  type        = number
  default     = 90
}

variable "dashboard_refresh_interval" {
  description = "Dashboard refresh interval in seconds"
  type        = number
  default     = 300
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
} 