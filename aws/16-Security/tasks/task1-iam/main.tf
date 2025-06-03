provider "aws" {
  region = var.aws_region
}

# Password Policy
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = var.password_policy.minimum_password_length
  require_lowercase             = var.password_policy.require_lowercase
  require_uppercase             = var.password_policy.require_uppercase
  require_numbers               = var.password_policy.require_numbers
  require_symbols               = var.password_policy.require_symbols
  allow_users_to_change_password = var.password_policy.allow_users_to_change_password
  max_password_age              = var.password_policy.max_password_age
  password_reuse_prevention     = var.password_policy.password_reuse_prevention
}

# IAM Groups
resource "aws_iam_group" "groups" {
  for_each    = { for group in var.iam_groups : group.name => group }
  name        = each.value.name
  path        = each.value.path
}

# Attach AWS managed policies to groups
resource "aws_iam_group_policy_attachment" "managed_policy_attachments" {
  for_each = {
    for policy in flatten([
      for group in var.iam_groups : [
        for policy in group.policies : {
          group_name = group.name
          policy_arn = policy
        }
      ]
    ]) : "${policy.group_name}-${policy.policy_arn}" => policy
  }
  group      = each.value.group_name
  policy_arn = each.value.policy_arn
  depends_on = [aws_iam_group.groups]
}

# IAM Users
resource "aws_iam_user" "users" {
  for_each = { for user in var.iam_users : user.username => user }
  name     = each.value.username
  tags     = merge(var.tags, each.value.tags)
}

# Add users to groups
resource "aws_iam_user_group_membership" "user_groups" {
  for_each = { for user in var.iam_users : user.username => user }
  user     = each.value.username
  groups   = each.value.groups
  depends_on = [
    aws_iam_user.users,
    aws_iam_group.groups
  ]
}

# MFA Policy
resource "aws_iam_policy" "require_mfa" {
  count       = var.require_mfa ? 1 : 0
  name        = "${var.project_name}-require-mfa"
  description = "Policy to enforce MFA usage"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowViewAccountInfo"
        Effect = "Allow"
        Action = [
          "iam:GetAccountPasswordPolicy",
          "iam:ListVirtualMFADevices"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowManageOwnVirtualMFADevice"
        Effect = "Allow"
        Action = [
          "iam:CreateVirtualMFADevice",
          "iam:DeleteVirtualMFADevice"
        ]
        Resource = "arn:aws:iam::*:mfa/$${aws:username}"
      },
      {
        Sid    = "AllowManageOwnUserMFA"
        Effect = "Allow"
        Action = [
          "iam:DeactivateMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ResyncMFADevice"
        ]
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid    = "DenyAllExceptListedIfNoMFA"
        Effect = "Deny"
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ResyncMFADevice",
          "sts:GetSessionToken"
        ]
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

# CloudWatch Logging
resource "aws_cloudwatch_log_group" "iam_logs" {
  count             = var.enable_cloudwatch_logging ? 1 : 0
  name              = "/aws/iam/${var.project_name}"
  retention_in_days = 30
  tags              = var.tags
}

# CloudWatch Metric Alarms for IAM
resource "aws_cloudwatch_metric_alarm" "root_account_usage" {
  count               = var.enable_cloudwatch_logging ? 1 : 0
  alarm_name          = "${var.project_name}-root-account-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "RootAccountUsage"
  namespace          = "AWS/IAM"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "This metric monitors root account usage"
  alarm_actions      = []  # Add SNS topic ARN if needed
  tags               = var.tags
}

# Access Key Rotation Check
resource "aws_cloudwatch_metric_alarm" "access_key_age" {
  count               = var.enable_cloudwatch_logging ? 1 : 0
  alarm_name          = "${var.project_name}-access-key-age"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "AccessKeyAge"
  namespace          = "AWS/IAM"
  period             = "86400"  # 1 day
  statistic          = "Maximum"
  threshold          = var.access_key_rotation_days
  alarm_description  = "This metric monitors the age of access keys"
  alarm_actions      = []  # Add SNS topic ARN if needed
  tags               = var.tags
} 