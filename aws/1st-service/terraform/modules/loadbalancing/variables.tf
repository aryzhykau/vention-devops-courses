variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "alb_sg_id" {
  type        = string
  description = "Security group ID for ALB"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for ALB"
}

variable "target_instance_id" {
  type        = string
  description = "EC2 instance ID to attach to ALB"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for ALB"
}

