module "s3_buckets" {
  source = "../module"

  for_each = {
    bucket1 = {
      name         = "my-test-bucket-1-petert800"
      versioning   = true
      encryption   = true
      block_public = true
      policy       = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Sid      = "DenyDelete"
          Effect   = "Deny"
          Principal = "*"
          Action   = "s3:DeleteBucket"
          Resource = "*"
        }]
      })
    },
    bucket2 = {
      name         = "my-test-bucket-2-petert800"
      versioning   = false
      encryption   = true
      block_public = false
      policy       = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Sid      = "AllowList"
          Effect   = "Allow"
          Principal = "*"
          Action   = "s3:ListBucket"
          Resource = "*"
        }]
      })
    }
  }

  bucket_name        = each.value.name
  enable_versioning  = each.value.versioning
  enable_encryption  = each.value.encryption
  block_public_access = each.value.block_public
  bucket_policy       = each.value.policy
}
