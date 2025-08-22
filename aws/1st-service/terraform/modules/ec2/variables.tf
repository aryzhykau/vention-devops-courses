variable "ami" { type = string }
variable "instance_type" { type = string }
variable "subnet_id" { type = string }
variable "key_name" { type = string }
variable "existing_sg_id" { type = string }
variable "environment" { type = string }
variable "iam_instance_profile_name" { type = string }

# user_data template inputs
variable "runner_repo_url" { type = string }
variable "runner_version" { type = string }
variable "runner_labels" { type = string }
variable "runner_token" {
  type      = string
  sensitive = true
  default   = null
}

