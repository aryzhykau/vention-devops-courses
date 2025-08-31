variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "ami" {}
variable "instance_type" {}
variable "subnet_id" {}

variable "alb_sg_id" {
  description = "Security Group ID for the Load Balancer"
  type        = string
}

