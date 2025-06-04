# KMS Key for RDS Encryption
resource "aws_kms_key" "rds_encryption" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                 = data.aws_iam_policy_document.kms_policy.json

  tags = merge(var.tags, {
    Name = "secure-rds-encryption-key"
  })
}

# KMS Key Alias
resource "aws_kms_alias" "rds_encryption" {
  name          = "alias/secure-rds-encryption"
  target_key_id = aws_kms_key.rds_encryption.key_id
}

# KMS Key Policy
data "aws_iam_policy_document" "kms_policy" {
  # Allow root account full access
  statement {
    sid    = "EnableIAMUserPermissions"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }

  # Allow RDS to use the key
  statement {
    sid    = "AllowRDSEncryption"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "rds.amazonaws.com"
      ]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }

  # Allow CloudWatch to use the key for log encryption
  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "logs.${data.aws_region.current.name}.amazonaws.com"
      ]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }

  # Allow authorized IAM users to use the key
  statement {
    sid    = "AllowKeyAdministration"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.rds_admin.arn
      ]
    }
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
  }
}

# SSL Certificate Configuration
resource "aws_acm_certificate" "rds" {
  domain_name       = "*.${var.database_domain}"
  validation_method = "DNS"

  tags = merge(var.tags, {
    Name = "secure-rds-certificate"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Certificate Validation
resource "aws_acm_certificate_validation" "rds" {
  certificate_arn = aws_acm_certificate.rds.arn
}

# Secrets Manager for Database Credentials
resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "secure-rds-credentials"
  description = "Credentials for secure RDS instance"
  kms_key_id  = aws_kms_key.rds_encryption.arn

  tags = merge(var.tags, {
    Name = "secure-rds-credentials"
  })
}

# Secret Version
resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    engine   = "mysql"
    host     = aws_db_instance.secure.endpoint
    port     = 3306
    dbname   = var.db_name
  })
}

# Secret Policy
resource "aws_secretsmanager_secret_policy" "rds_credentials" {
  secret_arn = aws_secretsmanager_secret.rds_credentials.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableIAMUserPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "secretsmanager:*"
        Resource = "*"
      },
      {
        Sid    = "AllowAppAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.application.arn
        }
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      }
    ]
  })
}

# Data Sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {} 