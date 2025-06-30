output "bucket_ids" {
  description = "The IDs of all created S3 buckets"
  value = {
    for k, bucket in aws_s3_bucket.this : k => bucket.id
  }
}

output "bucket_arns" {
  description = "The ARNs of all created S3 buckets"
  value = {
    for k, bucket in aws_s3_bucket.this : k => bucket.arn
  }
}

output "bucket_regions" {
  description = "The hardcoded region for all created S3 buckets"
  # If you want to use actual dynamic region, replace with bucket.region
  value = {
    for k, bucket in aws_s3_bucket.this : k => "eu-central-1"
  }
}


