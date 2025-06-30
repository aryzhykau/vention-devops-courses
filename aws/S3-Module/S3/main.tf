module "s3_buckets" {
  source  = "../module"
  buckets = var.buckets
}


