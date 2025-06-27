module "s3_buckets" {
  source = "../module"
  for_each = var.buckets

  bucket_config = each.value
}


