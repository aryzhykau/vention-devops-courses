variable "environment" { type = string }
variable "iam_policies" { type = map(object({ description = string, policy_filename = string })) }

