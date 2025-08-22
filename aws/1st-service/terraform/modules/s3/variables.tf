variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "allowed_principal_arns" {
  type    = list(string)
  default = []
}

variable "enable_versioning" {
  type    = bool
  default = false
}

variable "enable_cors" {
  type    = bool
  default = false
}

variable "force_destroy" {
  type    = bool
  default = false
}
