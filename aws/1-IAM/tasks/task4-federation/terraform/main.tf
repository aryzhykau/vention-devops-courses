provider "aws" {
  region = var.aws_region
}

# SAML Provider
resource "aws_iam_saml_provider" "main" {
  name                   = "${var.project_name}-saml-provider"
  saml_metadata_document = file(var.saml_metadata_path)

  tags = var.tags
}

# IAM Role for SAML Federation
resource "aws_iam_role" "saml_role" {
  name = "${var.project_name}-saml-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_saml_provider.main.arn
        }
        Action = "sts:AssumeRoleWithSAML"
        Condition = {
          StringEquals = {
            "SAML:aud" = "https://signin.aws.amazon.com/saml"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# OIDC Provider for Web Identity Federation
resource "aws_iam_openid_connect_provider" "main" {
  url = var.oidc_provider_url

  client_id_list = var.oidc_client_ids

  thumbprint_list = var.oidc_thumbprints

  tags = var.tags
}

# IAM Role for Web Identity Federation
resource "aws_iam_role" "oidc_role" {
  name = "${var.project_name}-oidc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.main.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider_url}:aud" = var.oidc_client_ids[0]
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Permission Set for Developers
resource "aws_iam_role_policy" "developer_permissions" {
  name = "${var.project_name}-developer-permissions"
  role = aws_iam_role.saml_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "ec2:Describe*",
          "rds:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion": var.allowed_regions
          }
        }
      }
    ]
  })
}

# Permission Set for Operators
resource "aws_iam_role_policy" "operator_permissions" {
  name = "${var.project_name}-operator-permissions"
  role = aws_iam_role.oidc_role.id

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
        Condition = {
          StringEquals = {
            "aws:RequestedRegion": var.allowed_regions
          }
          Bool = {
            "aws:MultiFactorAuthPresent": "true"
          }
        }
      }
    ]
  })
}

# CloudWatch Log Group for Federation Activity
resource "aws_cloudwatch_log_group" "federation_logs" {
  name              = "/aws/federation/${var.project_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# CloudWatch Metric Filter for Failed Federation Attempts
resource "aws_cloudwatch_metric_filter" "failed_federation" {
  name          = "${var.project_name}-failed-federation"
  pattern       = "{ $.eventName = AssumeRole* && $.errorCode = * }"
  log_group_name = aws_cloudwatch_log_group.federation_logs.name

  metric_transformation {
    name      = "FailedFederationCount"
    namespace = "FederationMetrics"
    value     = "1"
  }
}

# CloudWatch Alarm for Failed Federation Attempts
resource "aws_cloudwatch_metric_alarm" "failed_federation" {
  alarm_name          = "${var.project_name}-failed-federation"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FailedFederationCount"
  namespace           = "FederationMetrics"
  period             = "300"
  statistic          = "Sum"
  threshold          = "5"
  alarm_description  = "This metric monitors failed federation attempts"
  alarm_actions      = [var.sns_topic_arn]

  tags = var.tags
} 