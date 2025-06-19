provider "aws" {
  region = "us-east-1"
}

locals {
  s3_buckets = {
    bucket1 = {
      name                 = "my-test-bucket-1-petert800"
      versioning_enabled   = true
      public_access_block  = {
        block_public_acls       = true
        block_public_policy     = true
        ignore_public_acls      = true
        restrict_public_buckets = true
      }
      policy_path = "${path.module}/bucket1-policy.json"
    }

    bucket2 = {
      name                 = "my-test-bucket-2-petert800"
      versioning_enabled   = false
      public_access_block  = {
        block_public_acls       = false
        block_public_policy     = false
        ignore_public_acls      = false
        restrict_public_buckets = false
      }
      policy_path = "${path.module}/bucket2-policy.json"
    }
  }
}

module "s3_buckets" {
  source = "../module"

  for_each = local.s3_buckets

  bucket_name        = each.value.name
  versioning_enabled = each.value.versioning_enabled
  public_access_block = each.value.public_access_block
  bucket_policy       = file(each.value.policy_path)
}

