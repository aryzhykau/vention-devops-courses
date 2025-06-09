variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

# Launch Template Variables
variable "ami_id" {
  description = "ID of the AMI to use for the instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t3.micro"
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instances"
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = ""
}

variable "instance_profile_name" {
  description = "Name of the instance profile"
  type        = string
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 30
}

# Auto Scaling Group Variables
variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 4
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "target_group_arns" {
  description = "List of target group ARNs"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "health_check_type" {
  description = "Health check type (EC2 or ELB)"
  type        = string
  default     = "ELB"
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 300
}

variable "min_healthy_percentage" {
  description = "Minimum healthy percentage for instance refresh"
  type        = number
  default     = 50
}

variable "instance_warmup" {
  description = "Instance warmup time in seconds"
  type        = number
  default     = 300
}

# Scaling Policy Variables
variable "target_cpu_value" {
  description = "Target CPU utilization percentage"
  type        = number
  default     = 50
}

variable "target_requests_per_instance" {
  description = "Target requests per instance"
  type        = number
  default     = 1000
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB"
  type        = string
  default     = ""
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the target group"
  type        = string
  default     = ""
}

variable "cpu_high_threshold" {
  description = "CPU high threshold percentage"
  type        = number
  default     = 80
}

variable "cpu_low_threshold" {
  description = "CPU low threshold percentage"
  type        = number
  default     = 30
}

# Lifecycle Hook Variables
variable "lifecycle_hook_timeout" {
  description = "Lifecycle hook timeout in seconds"
  type        = number
  default     = 300
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for lifecycle hooks"
  type        = string
}

variable "lifecycle_hook_role_arn" {
  description = "IAM role ARN for lifecycle hooks"
  type        = string
}

# Scheduled Actions Variables
variable "enable_scheduled_actions" {
  description = "Enable scheduled scaling actions"
  type        = bool
  default     = false
}

variable "schedule_scale_up_min" {
  description = "Minimum size for scale up schedule"
  type        = number
  default     = 2
}

variable "schedule_scale_up_max" {
  description = "Maximum size for scale up schedule"
  type        = number
  default     = 4
}

variable "schedule_scale_up_desired" {
  description = "Desired capacity for scale up schedule"
  type        = number
  default     = 2
}

variable "schedule_scale_up_recurrence" {
  description = "Cron expression for scale up schedule"
  type        = string
  default     = "0 8 * * MON-FRI"
}

variable "schedule_scale_down_min" {
  description = "Minimum size for scale down schedule"
  type        = number
  default     = 1
}

variable "schedule_scale_down_max" {
  description = "Maximum size for scale down schedule"
  type        = number
  default     = 2
}

variable "schedule_scale_down_desired" {
  description = "Desired capacity for scale down schedule"
  type        = number
  default     = 1
}

variable "schedule_scale_down_recurrence" {
  description = "Cron expression for scale down schedule"
  type        = string
  default     = "0 18 * * MON-FRI"
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {} 