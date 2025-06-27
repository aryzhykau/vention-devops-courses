resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_config.name
  force_destroy = true

  tags = {
    Name = var.bucket_config.name
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.bucket_config.versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.bucket_config.encryption ? "AES256" : "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.bucket_config.block_public
  ignore_public_acls      = var.bucket_config.block_public
  block_public_policy     = var.bucket_config.block_public
  restrict_public_buckets = var.bucket_config.block_public
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = var.bucket_config.policy.sid
        Effect    = var.bucket_config.policy.effect
        Action    = var.bucket_config.policy.action
        Principal = var.bucket_config.policy.principal
        Resource  = "arn:aws:s3:::${aws_s3_bucket.this.id}"
      }
    ]
  })
}



