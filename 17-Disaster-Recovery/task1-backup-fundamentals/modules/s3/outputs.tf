output "bucket_name" {
  value = aws_s3_bucket.frontend.bucket
}

output "website_endpoint" {
  value = aws_s3_bucket.frontend.website_endpoint
}

