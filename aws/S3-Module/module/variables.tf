variable "buckets" {
  description = "Map of S3 bucket configurations"
  type = map(object({
    name         = string
    versioning   = bool
    encryption   = bool
    block_public = bool
    policy = object({
      sid       = string
      effect    = string
      action    = string
      principal = string
    })
  }))
}


