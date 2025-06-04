variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate in ACM"
  type        = string
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain ALB access logs"
  type        = number
  default     = 90
}

variable "api_health_check_path" {
  description = "Health check path for API target group"
  type        = string
  default     = "/health"
}

variable "static_health_check_path" {
  description = "Health check path for static content target group"
  type        = string
  default     = "/index.html"
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive health check successes required before considering a target healthy"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures required before considering a target unhealthy"
  type        = number
  default     = 10
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "api_health_check_matcher" {
  description = "HTTP response codes to use when checking for a successful response from API target group"
  type        = string
  default     = "200-299"
}

variable "static_health_check_matcher" {
  description = "HTTP response codes to use when checking for a successful response from static content target group"
  type        = string
  default     = "200"
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  type        = string
}

variable "high_5xx_threshold" {
  description = "Threshold for high 5XX error rate alarm"
  type        = number
  default     = 10
}

variable "high_4xx_threshold" {
  description = "Threshold for high 4XX error rate alarm"
  type        = number
  default     = 100
}

variable "high_latency_threshold" {
  description = "Threshold in seconds for high latency alarm"
  type        = number
  default     = 5
}

variable "create_dns_record" {
  description = "Whether to create Route53 DNS record for the ALB"
  type        = bool
  default     = true
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain name for the ALB"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
} 