variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
}

variable "public_access" {
  description = "Public access block configuration"
  type = object({
    block_public_acls       = bool
    ignore_public_acls      = bool
    block_public_policy     = bool
    restrict_public_buckets = bool
  })
}

variable "encryption_algorithm" {
  description = "SSE encryption algorithm to use"
  type        = string
  default     = "AES256"
}

variable "bucket_policy" {
  description = "JSON bucket policy content"
  type        = string
}
