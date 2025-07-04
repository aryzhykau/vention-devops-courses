variable "rds_username" {
  type        = string
  description = "Username for RDS"
}

variable "rds_password" {
  type        = string
  description = "Password for RDS"
  sensitive   = true
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name"
}
