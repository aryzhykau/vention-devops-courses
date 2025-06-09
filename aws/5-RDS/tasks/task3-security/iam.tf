# RDS Admin Role
resource "aws_iam_role" "rds_admin" {
  name = "secure-rds-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "RDS Admin Role"
  })
}

# RDS Admin Policy
resource "aws_iam_role_policy" "rds_admin" {
  name = "secure-rds-admin-policy"
  role = aws_iam_role.rds_admin.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:*",
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      }
    ]
  })
}

# Application Role
resource "aws_iam_role" "application" {
  name = "secure-rds-application-role"

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

  tags = merge(var.tags, {
    Name = "Application Role"
  })
}

# Application Policy
resource "aws_iam_role_policy" "application" {
  name = "secure-rds-application-policy"
  role = aws_iam_role.application.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect",
          "rds:DescribeDBInstances",
          "rds:ListTagsForResource"
        ]
        Resource = aws_db_instance.secure.arn
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.rds_credentials.arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.rds_encryption.arn
      }
    ]
  })
}

# Monitoring Role
resource "aws_iam_role" "monitoring" {
  name = "secure-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "RDS Monitoring Role"
  })
}

# Monitoring Policy
resource "aws_iam_role_policy_attachment" "monitoring" {
  role       = aws_iam_role.monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Audit Role
resource "aws_iam_role" "audit" {
  name = "secure-rds-audit-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "RDS Audit Role"
  })
}

# Audit Policy
resource "aws_iam_role_policy" "audit" {
  name = "secure-rds-audit-policy"
  role = aws_iam_role.audit.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/rds/audit/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = aws_kms_key.rds_encryption.arn
      }
    ]
  })
}

# Instance Profile for Application
resource "aws_iam_instance_profile" "application" {
  name = "secure-rds-application-profile"
  role = aws_iam_role.application.name

  tags = merge(var.tags, {
    Name = "Application Instance Profile"
  })
}

# Password Policy
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers               = true
  require_symbols               = true
  allow_users_to_change_password = true
  password_reuse_prevention     = 24
  max_password_age             = 90
} 