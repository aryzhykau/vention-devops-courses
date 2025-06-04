variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the hosted zone"
  type        = string
}

variable "zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "health_check_regions" {
  description = "List of regions to perform health checks from"
  type        = list(string)
  default     = ["us-west-2", "us-east-1", "eu-west-1"]
}

# Primary/Secondary Endpoints
variable "primary_endpoint" {
  description = "Primary endpoint domain name"
  type        = string
}

variable "primary_zone_id" {
  description = "Zone ID of the primary endpoint"
  type        = string
}

variable "secondary_endpoint" {
  description = "Secondary endpoint domain name"
  type        = string
}

variable "secondary_zone_id" {
  description = "Zone ID of the secondary endpoint"
  type        = string
}

# Regional Endpoints
variable "us_west_endpoint" {
  description = "US West endpoint domain name"
  type        = string
}

variable "us_west_zone_id" {
  description = "Zone ID of the US West endpoint"
  type        = string
}

variable "us_east_endpoint" {
  description = "US East endpoint domain name"
  type        = string
}

variable "us_east_zone_id" {
  description = "Zone ID of the US East endpoint"
  type        = string
}

variable "eu_west_endpoint" {
  description = "EU West endpoint domain name"
  type        = string
}

variable "eu_west_zone_id" {
  description = "Zone ID of the EU West endpoint"
  type        = string
}

variable "ap_northeast_endpoint" {
  description = "AP Northeast endpoint domain name"
  type        = string
}

variable "ap_northeast_zone_id" {
  description = "Zone ID of the AP Northeast endpoint"
  type        = string
}

# Multi-value Answer Endpoints
variable "multi_endpoint_1" {
  description = "First endpoint IP for multi-value answer"
  type        = string
}

variable "multi_endpoint_2" {
  description = "Second endpoint IP for multi-value answer"
  type        = string
}

variable "multi_endpoint_3" {
  description = "Third endpoint IP for multi-value answer"
  type        = string
}

# Monitoring
variable "sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  type        = string
} 