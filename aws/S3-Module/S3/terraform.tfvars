buckets = {
  bucket1 = {
    name         = "my-test-bucket-1-petert800"
    versioning   = true
    encryption   = true
    block_public = true
    policy = {
      sid       = "DenyDelete"
      effect    = "Deny"
      action    = "s3:DeleteBucket"
      principal = "*"
    }
  }

  bucket2 = {
    name         = "my-test-bucket-2-petert800"
    versioning   = false
    encryption   = true
    block_public = true
    policy = {
      sid       = "AllowList"
      effect    = "Allow"
      action    = "s3:ListBucket"
      principal = "*"
    }
  }
}

