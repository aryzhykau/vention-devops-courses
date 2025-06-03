# Lambda Execution Role
resource "aws_iam_role" "lambda_role" {
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

# CloudWatch Logs Policy
resource "aws_iam_role_policy" "lambda_logging" {
  name = "${var.project_name}-${var.environment}-lambda-logging"
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
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
        ]
      }
    ]
  })
}

# S3 Access Policy
resource "aws_iam_role_policy" "s3_access" {
  count = var.enable_s3_trigger ? 1 : 0

  name = "${var.project_name}-${var.environment}-s3-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetObjectVersion"
        ]
        Resource = [
          aws_s3_bucket.event_source[0].arn,
          "${aws_s3_bucket.event_source[0].arn}/*"
        ]
      }
    ]
  })
}

# SNS Policy
resource "aws_iam_role_policy" "sns_publish" {
  count = var.enable_sns ? 1 : 0

  name = "${var.project_name}-${var.environment}-sns-publish"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish",
          "sns:Subscribe"
        ]
        Resource = [
          aws_sns_topic.main[0].arn
        ]
      }
    ]
  })
}

# SQS Policy
resource "aws_iam_role_policy" "sqs_access" {
  count = var.enable_sqs ? 1 : 0

  name = "${var.project_name}-${var.environment}-sqs-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = [
          aws_sqs_queue.main[0].arn,
          var.enable_dlq ? aws_sqs_queue.dlq[0].arn : ""
        ]
      }
    ]
  })
}

# EventBridge Policy
resource "aws_iam_role_policy" "eventbridge" {
  count = var.enable_eventbridge ? 1 : 0

  name = "${var.project_name}-${var.environment}-eventbridge"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "events:PutEvents"
        ]
        Resource = [
          "arn:aws:events:${var.aws_region}:${data.aws_caller_identity.current.account_id}:event-bus/default"
        ]
      }
    ]
  })
}

# Cross-Account Access Policy
resource "aws_iam_role_policy" "cross_account" {
  count = var.enable_cross_account_events ? 1 : 0

  name = "${var.project_name}-${var.environment}-cross-account"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "events:PutEvents"
        ]
        Resource = [
          "arn:aws:events:*:*:event-bus/default"
        ]
      }
    ]
  })
}

# API Gateway Permissions
resource "aws_lambda_permission" "api_gateway" {
  count = var.enable_api_gateway ? 1 : 0

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api[0].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main[0].execution_arn}/*/*"
}

# S3 Bucket Permissions
resource "aws_lambda_permission" "s3" {
  count = var.enable_s3_trigger ? 1 : 0

  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3[0].function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.event_source[0].arn
}

# EventBridge Permissions
resource "aws_lambda_permission" "events" {
  count = var.enable_eventbridge ? 1 : 0

  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.events[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.main[0].arn
}

# SNS Topic Permissions
resource "aws_lambda_permission" "sns" {
  count = var.enable_sns ? 1 : 0

  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.queue[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.main[0].arn
}

# Data Sources
data "aws_caller_identity" "current" {} 