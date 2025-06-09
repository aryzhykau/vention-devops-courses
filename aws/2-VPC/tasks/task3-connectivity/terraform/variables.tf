variable "aws_region" {
  description = "AWS region for the main VPC"
  type        = string
  default     = "us-east-1"
}

variable "peer_region" {
  description = "AWS region for the peer VPC"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name to be used as prefix for all resources"
  type        = string
  default     = "demo"
}

variable "vpc_id" {
  description = "ID of the main VPC"
  type        = string
}

variable "peer_vpc_id" {
  description = "ID of the peer VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the main VPC"
  type        = string
}

variable "remote_cidr" {
  description = "CIDR block of the remote network for VPN connection"
  type        = string
}

variable "tgw_subnet_ids" {
  description = "List of subnet IDs for Transit Gateway attachment"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "List of private route table IDs"
  type        = list(string)
}

variable "endpoint_subnet_ids" {
  description = "List of subnet IDs for VPC endpoints"
  type        = list(string)
}

variable "customer_bgp_asn" {
  description = "BGP ASN for customer gateway"
  type        = number
  default     = 65000
}

variable "customer_ip" {
  description = "Public IP address of customer gateway"
  type        = string
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