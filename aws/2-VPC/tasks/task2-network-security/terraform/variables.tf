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

variable "vpc_id" {
  description = "ID of the VPC where resources will be created"
  type        = string
}

variable "admin_cidr" {
  description = "CIDR block for admin access (SSH)"
  type        = string
}

variable "monitoring_eni_id" {
  description = "ID of the ENI to use as traffic mirror target"
  type        = string
}

variable "firewall_subnet_id" {
  description = "ID of the subnet where Network Firewall will be deployed"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "blocked_requests_threshold" {
  description = "Threshold for blocked requests alarm"
  type        = number
  default     = 100
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