# Lambda Execution Role
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-${var.environment}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.function_name}-role"
    Environment = var.environment
  })
}

# CloudWatch Logs Policy
resource "aws_iam_role_policy" "lambda_logging" {
  name = "${var.function_name}-${var.environment}-logging"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "${aws_cloudwatch_log_group.lambda.arn}:*"
        ]
      }
    ]
  })
}

# X-Ray Policy (if enabled)
resource "aws_iam_role_policy_attachment" "lambda_xray" {
  count = var.enable_xray ? 1 : 0

  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# Basic Lambda Execution Policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# VPC Access Policy (if needed in future)
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count = 0  # Disabled by default, enable when VPC access is needed

  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Custom Policy for Additional Permissions
resource "aws_iam_role_policy" "lambda_custom" {
  count = length(var.environment_variables) > 0 ? 1 : 0

  name = "${var.function_name}-${var.environment}-custom"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = [
          "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/${var.function_name}/*"
        ]
      }
    ]
  })
}

# Data Sources
data "aws_caller_identity" "current" {} 