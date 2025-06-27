variable "bucket_config" {
  description = "Single bucket config passed from the root module"
  type = object({
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
  })
}


