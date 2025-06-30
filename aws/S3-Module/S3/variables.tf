variable "buckets" {
  description = "Map of bucket configurations passed to the S3 module"
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



