output "bucket_ids" {
  value = { for k, m in module.s3_buckets : k => m.bucket_id }
}

output "bucket_arns" {
  value = { for k, m in module.s3_buckets : k => m.bucket_arn }
}

output "bucket_regions" {
  value = { for k, m in module.s3_buckets : k => m.bucket_region }
}


