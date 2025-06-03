variable "project_name" {
  description = "Name of the project, used as prefix for all resources"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

# WAF Configuration
variable "enable_waf" {
  description = "Enable WAF protection"
  type        = bool
  default     = true
}

variable "waf_block_rules" {
  description = "List of WAF rules to block requests"
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules    = list(object({
      type    = string
      value   = string
    }))
  }))
  default = []
}

# Certificate Manager
variable "domain_name" {
  description = "Domain name for SSL certificate"
  type        = string
}

variable "alternative_names" {
  description = "Alternative domain names for SSL certificate"
  type        = list(string)
  default     = []
}

# Secrets Manager
variable "enable_secrets_manager" {
  description = "Enable Secrets Manager"
  type        = bool
  default     = true
}

variable "secrets" {
  description = "List of secrets to store"
  type = list(object({
    name        = string
    description = string
    type        = string
  }))
  default = []
}

# CloudWatch Monitoring
variable "enable_monitoring" {
  description = "Enable enhanced monitoring and alerting"
  type        = bool
  default     = true
}

variable "alert_email" {
  description = "Email address for security alerts"
  type        = string
  default     = ""
}

# Security Headers
variable "security_headers" {
  description = "Security headers to add to responses"
  type = object({
    hsts                    = bool
    content_security_policy = bool
    x_frame_options         = bool
    x_content_type_options  = bool
    referrer_policy        = bool
  })
  default = {
    hsts                    = true
    content_security_policy = true
    x_frame_options         = true
    x_content_type_options  = true
    referrer_policy        = true
  }
}

# Load Balancer
variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the load balancer"
  type        = list(string)
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