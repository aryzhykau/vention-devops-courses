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

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# Security Group Rules
variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH to bastion"
  type        = list(string)
  default     = []
}

variable "allowed_http_cidrs" {
  description = "List of CIDR blocks allowed for HTTP access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Flow Logs
variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain flow logs"
  type        = number
  default     = 7
}

# Bastion Host
variable "bastion_instance_type" {
  description = "Instance type for bastion host (Free Tier eligible)"
  type        = string
  default     = "t2.micro"
}

variable "bastion_key_name" {
  description = "Name of the key pair for bastion host"
  type        = string
}

# VPC Endpoints
variable "enable_s3_endpoint" {
  description = "Enable S3 VPC Endpoint"
  type        = bool
  default     = true
}

variable "enable_dynamodb_endpoint" {
  description = "Enable DynamoDB VPC Endpoint"
  type        = bool
  default     = false
}

# Network ACL Rules
variable "custom_nacl_rules" {
  description = "Custom Network ACL rules"
  type = list(object({
    rule_number = number
    egress     = bool
    protocol   = string
    rule_action = string
    cidr_block = string
    from_port  = number
    to_port    = number
  }))
  default = []
}

# Monitoring
variable "enable_monitoring" {
  description = "Enable enhanced monitoring and alerting"
  type        = bool
  default     = true
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