variable "project_name" {
  description = "Name of the project, used as prefix for all resources"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# ECS Variables
variable "ecs_instance_type" {
  description = "EC2 instance type for ECS container instances (Free Tier eligible)"
  type        = string
  default     = "t2.micro"
}

variable "ecs_min_instances" {
  description = "Minimum number of EC2 instances in the ECS cluster"
  type        = number
  default     = 1
}

variable "ecs_max_instances" {
  description = "Maximum number of EC2 instances in the ECS cluster (limited for Free Tier)"
  type        = number
  default     = 2
}

variable "ecs_desired_instances" {
  description = "Desired number of EC2 instances in the ECS cluster"
  type        = number
  default     = 1
}

# Task Definition Variables
variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "app"
}

variable "container_image" {
  description = "Docker image for the container"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

variable "task_cpu" {
  description = "CPU units for the task (limited for t2.micro compatibility)"
  type        = number
  default     = 128
}

variable "task_memory" {
  description = "Memory for the task in MiB (limited for t2.micro compatibility)"
  type        = number
  default     = 256
}

# Service Variables
variable "service_desired_count" {
  description = "Desired number of tasks running in the service"
  type        = number
  default     = 1
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 60
}

# Volume Configuration
variable "root_volume_size" {
  description = "Size of the root EBS volume in GB (Free Tier eligible)"
  type        = number
  default     = 8
}

# Tags
variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {
    Environment = "development"
    ManagedBy   = "terraform"
  }
} 