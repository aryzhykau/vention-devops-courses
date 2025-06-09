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

variable "application_name" {
  description = "Name of the application"
  type        = string
  default     = "example-app"
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group to monitor"
  type        = string
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alerts"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "cpu_threshold" {
  description = "CPU utilization threshold percentage for alarm"
  type        = number
  default     = 80
}

variable "memory_threshold" {
  description = "Memory utilization threshold percentage for alarm"
  type        = number
  default     = 80
}

variable "disk_threshold" {
  description = "Disk space utilization threshold percentage for alarm"
  type        = number
  default     = 85
}

variable "error_threshold" {
  description = "Number of errors threshold for alarm"
  type        = number
  default     = 10
} 