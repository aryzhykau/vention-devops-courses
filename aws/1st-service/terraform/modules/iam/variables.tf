variable "environment" {
  description = "Environment name"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN"
  type        = string
}

variable "rds_arn" {
  description = "RDS ARN"
  type        = string
}
