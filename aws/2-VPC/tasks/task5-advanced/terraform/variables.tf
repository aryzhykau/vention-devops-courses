variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name to be used as prefix for all resources"
  type        = string
  default     = "demo"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "List of private route table IDs"
  type        = list(string)
}

variable "shared_subnet_ids" {
  description = "List of subnet IDs to share via AWS RAM"
  type        = list(string)
}

variable "participant_account_ids" {
  description = "List of AWS account IDs to share resources with"
  type        = list(string)
}

variable "nlb_arn" {
  description = "ARN of the Network Load Balancer for PrivateLink"
  type        = string
}

variable "allowed_principals" {
  description = "List of AWS principal ARNs allowed to use the endpoint service"
  type        = list(string)
}

variable "resolver_subnet_ids" {
  description = "List of subnet IDs for Route 53 Resolver endpoints"
  type        = list(string)
}

variable "forward_domain" {
  description = "Domain name for Route 53 Resolver forwarding rule"
  type        = string
}

variable "dns_target_ips" {
  description = "List of target IP addresses for DNS forwarding"
  type        = list(string)
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
  }
} 