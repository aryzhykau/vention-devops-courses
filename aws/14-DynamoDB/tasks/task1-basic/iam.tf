# Lambda Execution Role
resource "aws_iam_role" "lambda_role" {
  count = var.enable_lambda_trigger ? 1 : 0

  name = "${var.project_name}-${var.environment}-lambda-role"

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
    Name        = "${var.project_name}-lambda-role"
    Environment = var.environment
  })
}

# Lambda Basic Execution Policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  count = var.enable_lambda_trigger ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role[0].name
}

# DynamoDB Access Policy for Lambda
resource "aws_iam_role_policy" "dynamodb_access" {
  count = var.enable_lambda_trigger ? 1 : 0

  name = "${var.project_name}-${var.environment}-dynamodb-access"
  role = aws_iam_role.lambda_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          aws_dynamodb_table.main.arn,
          "${aws_dynamodb_table.main.arn}/index/*"
        ]
      }
    ]
  })
}

# Auto Scaling Role
resource "aws_iam_role" "autoscaling_role" {
  count = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? 1 : 0

  name = "${var.project_name}-${var.environment}-autoscaling-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "application-autoscaling.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.project_name}-autoscaling-role"
    Environment = var.environment
  })
}

# Auto Scaling Policy
resource "aws_iam_role_policy" "autoscaling_policy" {
  count = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? 1 : 0

  name = "${var.project_name}-${var.environment}-autoscaling-policy"
  role = aws_iam_role.autoscaling_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:UpdateTable",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DeleteAlarms"
        ]
        Resource = [
          aws_dynamodb_table.main.arn,
          "arn:aws:cloudwatch:${var.aws_region}:${data.aws_caller_identity.current.account_id}:alarm:*"
        ]
      }
    ]
  })
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "alerts" {
  count = var.enable_monitoring && var.alert_email != "" ? 1 : 0

  arn = aws_sns_topic.alerts[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchAlarms"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.alerts[0].arn
      }
    ]
  })
}

# Data Sources
data "aws_caller_identity" "current" {} 