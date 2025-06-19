resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = var.public_access.block_public_acls
  ignore_public_acls      = var.public_access.ignore_public_acls
  block_public_policy     = var.public_access.block_public_policy
  restrict_public_buckets = var.public_access.restrict_public_buckets
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.encryption_algorithm
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = var.bucket_policy
}
