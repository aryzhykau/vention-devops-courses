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
  description = "VPC ID where the NLB will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the NLB"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate in ACM"
  type        = string
}

variable "ssl_policy" {
  description = "SSL policy for TLS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for NLB"
  type        = bool
  default     = true
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

variable "tcp_port" {
  description = "Port for TCP listener"
  type        = number
  default     = 80
}

variable "udp_port" {
  description = "Port for UDP listener"
  type        = number
  default     = 53
}

variable "tls_port" {
  description = "Port for TLS listener"
  type        = number
  default     = 443
}

variable "udp_health_check_port" {
  description = "Port for UDP target group health check"
  type        = number
  default     = 53
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive health check successes required before considering a target healthy"
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures required before considering a target unhealthy"
  type        = number
  default     = 3
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  type        = string
}

variable "tcp_reset_threshold" {
  description = "Threshold for TCP reset count alarm"
  type        = number
  default     = 100
}

variable "tls_error_threshold" {
  description = "Threshold for TLS error count alarm"
  type        = number
  default     = 10
}

variable "create_dns_record" {
  description = "Whether to create Route53 DNS record for the NLB"
  type        = bool
  default     = true
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain name for the NLB"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
} 