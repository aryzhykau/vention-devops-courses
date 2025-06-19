output "bucket_ids" {
  description = "IDs of the created S3 buckets"
  value = {
    for name, mod in module.s3_buckets :
    name => mod.bucket_id
  }
}

