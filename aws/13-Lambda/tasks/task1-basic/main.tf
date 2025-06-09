# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Lambda Function
resource "aws_lambda_function" "main" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = "${var.function_name}-${var.environment}"
  role            = aws_iam_role.lambda_role.arn
  handler         = var.handler
  runtime         = var.runtime
  memory_size     = var.memory_size
  timeout         = var.timeout

  environment {
    variables = merge(
      var.environment_variables,
      {
        ENVIRONMENT = var.environment
      }
    )
  }

  tracing_config {
    mode = var.enable_xray ? "Active" : "PassThrough"
  }

  reserved_concurrent_executions = var.reserved_concurrent_executions

  tags = merge(var.tags, {
    Name        = var.function_name
    Environment = var.environment
  })
}

# Function URL (if enabled)
resource "aws_lambda_function_url" "main" {
  count = var.enable_function_url ? 1 : 0

  function_name      = aws_lambda_function.main.function_name
  authorization_type = var.function_url_auth_type
}

# Provisioned Concurrency (if enabled)
resource "aws_lambda_alias" "provisioned" {
  count = var.enable_provisioned_concurrency ? 1 : 0

  name             = "provisioned"
  description      = "Alias for provisioned concurrency"
  function_name    = aws_lambda_function.main.function_name
  function_version = aws_lambda_function.main.version
}

resource "aws_lambda_provisioned_concurrency_config" "main" {
  count = var.enable_provisioned_concurrency ? 1 : 0

  function_name                     = aws_lambda_function.main.function_name
  provisioned_concurrent_executions = var.provisioned_concurrent_executions
  qualifier                        = aws_lambda_alias.provisioned[0].name
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.main.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name        = "${var.function_name}-logs"
    Environment = var.environment
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "error_rate" {
  count = var.enable_cloudwatch_alerts ? 1 : 0

  alarm_name          = "${var.function_name}-${var.environment}-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "Errors"
  namespace          = "AWS/Lambda"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.error_rate_threshold
  alarm_description  = "Lambda function error rate monitor"
  alarm_actions      = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    FunctionName = aws_lambda_function.main.function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "duration" {
  count = var.enable_cloudwatch_alerts ? 1 : 0

  alarm_name          = "${var.function_name}-${var.environment}-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "Duration"
  namespace          = "AWS/Lambda"
  period             = "300"
  statistic          = "Average"
  threshold          = var.duration_threshold
  alarm_description  = "Lambda function duration monitor"
  alarm_actions      = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    FunctionName = aws_lambda_function.main.function_name
  }
}

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  count = var.enable_cloudwatch_alerts && var.alert_email != "" ? 1 : 0

  name = "${var.function_name}-${var.environment}-alerts"

  tags = merge(var.tags, {
    Name        = "${var.function_name}-alerts"
    Environment = var.environment
  })
}

# Email Subscription for Alerts
resource "aws_sns_topic_subscription" "alerts_email" {
  count = var.enable_cloudwatch_alerts && var.alert_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Lambda Function Code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/dist/${var.function_name}.zip"
}

# Create source directory and handler file if they don't exist
resource "local_file" "handler" {
  filename = "${path.module}/src/handler.py"
  content  = <<-EOF
import json
import logging
import os

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    """
    Basic Lambda handler function
    """
    logger.info(f"Processing event: {event}")
    
    try:
        # Get environment
        environment = os.environ.get('ENVIRONMENT', 'dev')
        
        # Process event
        result = process_event(event)
        
        # Return success response
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Success',
                'environment': environment,
                'data': result
            })
        }
    except Exception as e:
        logger.error(f"Error processing event: {str(e)}", exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Error',
                'error': str(e)
            })
        }

def process_event(event):
    """
    Process the incoming event
    """
    return {
        'processed': True,
        'event': event
    }
EOF
}

resource "local_file" "requirements" {
  filename = "${path.module}/src/requirements.txt"
  content  = <<-EOF
# No external dependencies for basic function
# Add dependencies here as needed
EOF
} 