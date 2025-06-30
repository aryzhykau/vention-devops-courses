resource "aws_s3_bucket" "this" {
  for_each = var.buckets

  bucket        = each.value.name
  force_destroy = true

  tags = {
    Name = each.value.name
  }
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = var.buckets

  bucket = aws_s3_bucket.this[each.key].id

  versioning_configuration {
    status = each.value.versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = var.buckets

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = each.value.encryption ? "AES256" : "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = var.buckets

  bucket = aws_s3_bucket.this[each.key].id

  block_public_acls       = each.value.block_public
  ignore_public_acls      = each.value.block_public
  block_public_policy     = each.value.block_public
  restrict_public_buckets = each.value.block_public
}

resource "aws_s3_bucket_policy" "this" {
  for_each = var.buckets

  bucket = aws_s3_bucket.this[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = each.value.policy.sid
        Effect    = each.value.policy.effect
        Action    = each.value.policy.action
        Principal = each.value.policy.principal
        Resource  = "arn:aws:s3:::${aws_s3_bucket.this[each.key].id}"
      }
    ]
  })
}

