# IAM Module

## Description
Module for creating IAM roles and policies for EC2 instances.

## Requirements
- Create IAM role for EC2 instances
- Create policies for S3 and RDS access
- Create instance profile
- Configure trust policy for EC2

## Hints
- Use `aws_iam_role` with assume role policy for EC2
- Create separate policies for S3 and RDS
- Apply least privilege principle
- Use `aws_iam_instance_profile` to attach role to EC2

## Variables (variables.tf)
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN"
  type        = string
}

variable "rds_arn" {
  description = "RDS ARN"
  type        = string
}
```

## Outputs (outputs.tf)
```hcl
output "ec2_role_arn" {
  description = "EC2 IAM role ARN"
  value       = aws_iam_role.ec2_role.arn
}

output "instance_profile_name" {
  description = "Instance profile name"
  value       = aws_iam_instance_profile.ec2_profile.name
}
```

## S3 Policy Example
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::bucket-name",
        "arn:aws:s3:::bucket-name/*"
      ]
    }
  ]
}
```

## RDS Policy Example
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "rds-db:connect"
      ],
      "Resource": [
        "arn:aws:rds-db:region:account:dbuser:db-instance-id/db-username"
      ]
    }
  ]
}
```

## Trust Policy for EC2
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
``` 