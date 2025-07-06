# S3 Module

## Description
Module for creating S3 bucket for storing user files.

## Requirements
- Create S3 bucket for files
- Configure CORS for web application
- Configure bucket policy for security
- Enable versioning
- Configure lifecycle policy (optional)

## Hints
- Use unique bucket name (globally unique)
- CORS should allow GET, POST, PUT, DELETE methods
- Bucket policy should allow access only to authorized users
- Enable server-side encryption
- Configure public access block

## Variables (variables.tf)
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "aws-1st-service"
}
```

## Outputs (outputs.tf)
```hcl
output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.main.bucket
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.main.arn
}
```

## CORS Configuration
```json
[
  {
    "AllowedHeaders": ["*"],
    "AllowedMethods": ["GET", "POST", "PUT", "DELETE"],
    "AllowedOrigins": ["*"],
    "ExposeHeaders": ["ETag"]
  }
]
```

## Bucket Policy Example
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAuthorizedUsers",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::ACCOUNT-ID:role/ec2-role"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::bucket-name/*",
      "Condition": {
        "StringEquals": {
          "aws:PrincipalArn": "arn:aws:iam::ACCOUNT-ID:role/ec2-role"
        }
      }
    }
  ]
}
``` 