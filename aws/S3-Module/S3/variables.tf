variable "buckets" {
  description = "Map of buckets"
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


