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

variable "static_bucket_name" {
  description = "Name of the S3 bucket for static content"
  type        = string
}

variable "backup_bucket_name" {
  description = "Name of the S3 bucket for backup content"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the CloudFront distribution"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "alb_domain_name" {
  description = "Domain name of the Application Load Balancer"
  type        = string
}

variable "custom_header_value" {
  description = "Value for the custom origin header"
  type        = string
  sensitive   = true
}

variable "field_level_encryption_public_key" {
  description = "Public key for field-level encryption"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  type        = string
}

variable "waf_web_acl_id" {
  description = "ID of the WAF Web ACL"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  type        = string
}

variable "price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100"
  
  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.price_class)
    error_message = "Price class must be one of PriceClass_100, PriceClass_200, or PriceClass_All"
  }
}

variable "allowed_countries" {
  description = "List of countries allowed to access the distribution"
  type        = list(string)
  default     = ["US", "CA", "GB", "DE"]
  
  validation {
    condition     = length(var.allowed_countries) > 0
    error_message = "At least one country must be specified"
  }
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
} 