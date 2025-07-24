variable "environment" {
  description = "Environment name"
  type        = string
}

variable "iam_policies" {
  description = "Map of IAM policies with filenames and descriptions"
  type = map(object({
    description     = string
    policy_filename = string
  }))
}

