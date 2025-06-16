variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-west-2"
}

variable "ingress_rules" {
  description = "Ingress rules for the security group"
  type = map(object({
    from_port = number
    to_port   = number
    cidr      = string
  }))
  default = {
    "http" = {
      from_port = 80
      to_port   = 80
      cidr      = "0.0.0.0/0"
    },
    "ssh" = {
      from_port = 22
      to_port   = 22
      cidr      = "0.0.0.0/0"  
    }
  }
}

variable "subnets" {
  description = "Subnets configuration"
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    "public-a" = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-west-2a"
    }
  }
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0735c191cf914754d"  # Amazon Linux 2 for us-west-2
}

variable "instance_type" {
  description = "Instance type for EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "SSH key pair name"
  type        = string
  default     = "deployer-key"
}

variable "public_key_path" {
  description = "Path to your local public SSH key"
  type        = string
  default     = "/home/ubuntu/.ssh/id_rsa.pub"
}

variable "ebs_volume_size" {
  description = "Size of the additional EBS volume (in GiB)"
  type        = number
  default     = 20
}

variable "tags" {
  description = "Common tags applied to all resources"
  type = map(string)
  default = {
    Environment = "dev"
    Owner       = "peter"
  }
}

