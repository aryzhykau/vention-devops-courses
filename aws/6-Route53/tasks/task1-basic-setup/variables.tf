variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "domain_name" {
  description = "Domain name for the hosted zone"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., Production, Staging)"
  type        = string
  default     = "Production"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  type        = string
}

variable "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  type        = string
}

variable "mx_records" {
  description = "List of MX records"
  type        = list(string)
  default     = [
    "10 mail1.example.com",
    "20 mail2.example.com"
  ]
}

variable "txt_records" {
  description = "List of TXT records"
  type        = list(string)
  default     = [
    "v=spf1 include:_spf.example.com ~all"
  ]
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  type        = string
}

variable "query_threshold" {
  description = "Threshold for DNS query volume alarm"
  type        = number
  default     = 10000
}

variable "s3_website_domain" {
  description = "Domain name of the S3 static website"
  type        = string
}

variable "s3_website_zone_id" {
  description = "Zone ID of the S3 static website"
  type        = string
}

variable "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  type        = string
}

variable "cloudfront_hosted_zone_id" {
  description = "Hosted zone ID of the CloudFront distribution"
  type        = string
}

variable "api_gateway_domain_name" {
  description = "Domain name of the API Gateway"
  type        = string
}

variable "api_gateway_zone_id" {
  description = "Zone ID of the API Gateway"
  type        = string
} 