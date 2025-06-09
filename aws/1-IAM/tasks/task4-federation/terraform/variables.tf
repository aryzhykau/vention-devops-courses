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

variable "saml_metadata_path" {
  description = "Path to the SAML metadata XML file"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider"
  type        = string
}

variable "oidc_client_ids" {
  description = "List of client IDs for the OIDC provider"
  type        = list(string)
}

variable "oidc_thumbprints" {
  description = "List of thumbprints for the OIDC provider"
  type        = list(string)
}

variable "allowed_regions" {
  description = "List of AWS regions where access is allowed"
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
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