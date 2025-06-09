provider "aws" {
  region = var.aws_region
}

# Least Privilege Policies

# S3 Access Policy
resource "aws_iam_policy" "s3_access" {
  name        = "${var.project_name}-s3-access"
  description = "Limited S3 access policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}

# EC2 Management Policy
resource "aws_iam_policy" "ec2_management" {
  name        = "${var.project_name}-ec2-management"
  description = "Limited EC2 management policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Environment": var.environment
          }
        }
      }
    ]
  })
}

# Permission Boundaries

# Developer Permission Boundary
resource "aws_iam_policy" "developer_boundary" {
  name        = "${var.project_name}-developer-boundary"
  description = "Permission boundary for developers"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "ec2:Describe*",
          "rds:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*"
        ]
        Resource = "*"
      },
      {
        Effect = "Deny"
        Action = [
          "iam:*",
          "organizations:*",
          "account:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Operator Permission Boundary
resource "aws_iam_policy" "operator_boundary" {
  name        = "${var.project_name}-operator-boundary"
  description = "Permission boundary for operators"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "rds:*",
          "s3:*",
          "cloudwatch:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Deny"
        Action = [
          "iam:*",
          "organizations:*",
          "account:*",
          "kms:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Conditional Policies

# MFA Required Policy
resource "aws_iam_policy" "mfa_required" {
  name        = "${var.project_name}-mfa-required"
  description = "Policy requiring MFA for sensitive operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StopInstances",
          "ec2:TerminateInstances",
          "rds:DeleteDBInstance",
          "s3:DeleteBucket"
        ]
        Resource = "*"
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent": "true"
          }
        }
      }
    ]
  })
}

# Time-Based Access Policy
resource "aws_iam_policy" "business_hours" {
  name        = "${var.project_name}-business-hours"
  description = "Policy allowing access during business hours"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "rds:*"
        ]
        Resource = "*"
        Condition = {
          DateGreaterThan = {
            "aws:CurrentTime": "2023-01-01T09:00:00Z"
          }
          DateLessThan = {
            "aws:CurrentTime": "2023-12-31T17:00:00Z"
          }
        }
      }
    ]
  })
}

# Example Group with Policies
resource "aws_iam_group" "developers" {
  name = "${var.project_name}-developers"
}

resource "aws_iam_group_policy_attachment" "developer_policy" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# Example Role with Permission Boundary
resource "aws_iam_role" "developer_role" {
  name                 = "${var.project_name}-developer-role"
  permissions_boundary = aws_iam_policy.developer_boundary.arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# CloudWatch Log Group for Policy Usage Monitoring
resource "aws_cloudwatch_log_group" "policy_usage" {
  name              = "/aws/iam/${var.project_name}-policy-usage"
  retention_in_days = var.log_retention_days

  tags = var.tags
} 