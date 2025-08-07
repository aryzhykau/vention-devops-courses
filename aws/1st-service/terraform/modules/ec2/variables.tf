variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "existing_sg_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name to attach to the EC2 instance"
  type        = string
}
