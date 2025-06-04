provider "aws" {
  region = var.aws_region
  alias  = "target"
}

provider "aws" {
  region = var.aws_region
  alias  = "source"
}

# Cross-Account Role in Target Account
resource "aws_iam_role" "cross_account_role" {
  provider = aws.target
  name     = "${var.project_name}-cross-account-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.source_account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Cross-Account Access Policy
resource "aws_iam_role_policy" "cross_account_policy" {
  provider = aws.target
  name     = "${var.project_name}-cross-account-policy"
  role     = aws_iam_role.cross_account_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.target_bucket}",
          "arn:aws:s3:::${var.target_bucket}/*"
        ]
      },
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

# Source Account Policy to Assume Role
resource "aws_iam_policy" "assume_role_policy" {
  provider    = aws.source
  name        = "${var.project_name}-assume-role-policy"
  description = "Policy to allow assuming cross-account role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Resource = [
          aws_iam_role.cross_account_role.arn
        ]
        Condition = {
          StringEquals = {
            "sts:ExternalId": var.external_id
          }
        }
      }
    ]
  })
}

# Group in Source Account
resource "aws_iam_group" "cross_account_group" {
  provider = aws.source
  name     = "${var.project_name}-cross-account-users"
}

# Attach Assume Role Policy to Group
resource "aws_iam_group_policy_attachment" "cross_account_attach" {
  provider   = aws.source
  group      = aws_iam_group.cross_account_group.name
  policy_arn = aws_iam_policy.assume_role_policy.arn
}

# CloudTrail for Monitoring Cross-Account Activity
resource "aws_cloudtrail" "cross_account_trail" {
  provider                      = aws.target
  name                         = "${var.project_name}-cross-account-trail"
  s3_bucket_name              = var.cloudtrail_bucket
  include_global_service_events = true
  is_multi_region_trail        = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = var.tags
}

# CloudWatch Log Group for Cross-Account Activity
resource "aws_cloudwatch_log_group" "cross_account_logs" {
  provider          = aws.target
  name              = "/aws/cross-account/${var.project_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# CloudWatch Metric Filter for Failed Assume Role
resource "aws_cloudwatch_metric_filter" "failed_assume_role" {
  provider      = aws.target
  name          = "${var.project_name}-failed-assume-role"
  pattern       = "{ $.eventName = AssumeRole && $.errorCode = * }"
  log_group_name = aws_cloudwatch_log_group.cross_account_logs.name

  metric_transformation {
    name      = "FailedAssumeRoleCount"
    namespace = "CrossAccountMetrics"
    value     = "1"
  }
}

# CloudWatch Alarm for Failed Assume Role
resource "aws_cloudwatch_metric_alarm" "failed_assume_role" {
  provider            = aws.target
  alarm_name          = "${var.project_name}-failed-assume-role"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FailedAssumeRoleCount"
  namespace           = "CrossAccountMetrics"
  period             = "300"
  statistic          = "Sum"
  threshold          = "5"
  alarm_description  = "This metric monitors failed assume role attempts"
  alarm_actions      = [var.sns_topic_arn]

  tags = var.tags
} 