output "bucket_ids" {
  value = {
    for name, m in module.s3_buckets :
    name => m.bucket_id
  }
}

