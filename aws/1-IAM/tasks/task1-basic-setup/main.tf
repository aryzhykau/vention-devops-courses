# Configure AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Create IAM Group for developers
resource "aws_iam_group" "developers" {
  name = "developers"
}

# Create IAM users
resource "aws_iam_user" "developers" {
  count = 3
  name  = "developer-${count.index + 1}"

  tags = {
    Department = "Engineering"
    Role       = "Developer"
  }
}

# Add users to group
resource "aws_iam_user_group_membership" "developers" {
  count = 3
  user  = aws_iam_user.developers[count.index].name
  groups = [aws_iam_group.developers.name]
}

# Create IAM role for EC2 access
resource "aws_iam_role" "developer_role" {
  name = "developer-role"

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

# Set password policy
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 12
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers               = true
  require_symbols               = true
  allow_users_to_change_password = true
  password_reuse_prevention     = 24
  max_password_age             = 90
}

# Create access keys for users
resource "aws_iam_access_key" "developer_keys" {
  count = 3
  user  = aws_iam_user.developers[count.index].name
}

# Enable MFA policy
resource "aws_iam_group_policy" "require_mfa" {
  name  = "require-mfa"
  group = aws_iam_group.developers.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:ResyncMFADevice",
          "iam:DeleteVirtualMFADevice"
        ]
        Resource = [
          "arn:aws:iam::*:mfa/*",
          "arn:aws:iam::*:user/$${aws:username}"
        ]
      },
      {
        Effect = "Deny"
        NotAction = "iam:*"
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}

# Set up CloudWatch rule for access key rotation
resource "aws_cloudwatch_event_rule" "access_key_rotation" {
  name                = "access-key-rotation"
  description         = "Check for access keys older than 90 days"
  schedule_expression = "rate(1 day)"

  event_pattern = jsonencode({
    source      = ["aws.iam"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["iam.amazonaws.com"]
      eventName   = ["CreateAccessKey"]
    }
  })
}

# Create SNS topic for notifications
resource "aws_sns_topic" "access_key_rotation" {
  name = "access-key-rotation"
}

# Set up CloudWatch event target
resource "aws_cloudwatch_event_target" "access_key_rotation" {
  rule      = aws_cloudwatch_event_rule.access_key_rotation.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.access_key_rotation.arn
}

# Output important information
output "group_arn" {
  value = aws_iam_group.developers.arn
}

output "user_arns" {
  value = aws_iam_user.developers[*].arn
}

output "role_arn" {
  value = aws_iam_role.developer_role.arn
} 