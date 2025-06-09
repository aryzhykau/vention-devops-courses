# EventBridge Rule
resource "aws_cloudwatch_event_rule" "main" {
  count = var.enable_eventbridge ? 1 : 0

  name                = "${var.project_name}-${var.environment}-rule"
  description         = "EventBridge rule for Lambda function"
  schedule_expression = var.eventbridge_schedule
  event_pattern      = var.eventbridge_event_pattern

  tags = merge(var.tags, {
    Name        = "${var.project_name}-rule"
    Environment = var.environment
  })
}

# EventBridge Target
resource "aws_cloudwatch_event_target" "lambda" {
  count = var.enable_eventbridge ? 1 : 0

  rule      = aws_cloudwatch_event_rule.main[0].name
  target_id = "LambdaFunction"
  arn       = aws_lambda_function.events[0].arn

  retry_policy {
    maximum_event_age_in_seconds = 3600
    maximum_retry_attempts       = 2
  }

  dead_letter_config {
    arn = var.enable_dlq ? aws_sqs_queue.dlq[0].arn : null
  }
}

# Cross-Account Event Bus Policy (if enabled)
resource "aws_cloudwatch_event_bus_policy" "cross_account" {
  count = var.enable_eventbridge && var.enable_cross_account_events ? 1 : 0

  event_bus_name = "default"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCrossAccountAccess"
        Effect    = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "events:PutEvents"
        ]
        Resource = "arn:aws:events:${var.aws_region}:${data.aws_caller_identity.current.account_id}:event-bus/default"
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = data.aws_organizations_organization.current[0].id
          }
        }
      }
    ]
  })
}

# Organizations Data Source (for cross-account events)
data "aws_organizations_organization" "current" {
  count = var.enable_eventbridge && var.enable_cross_account_events ? 1 : 0
}

# CloudWatch Log Group for Events
resource "aws_cloudwatch_log_group" "events" {
  count = var.enable_eventbridge ? 1 : 0

  name              = "/aws/lambda/${var.project_name}-${var.environment}-events"
  retention_in_days = var.lambda_log_retention_days

  tags = merge(var.tags, {
    Name        = "${var.project_name}-events-logs"
    Environment = var.environment
  })
}

# CloudWatch Metric Alarm for Events
resource "aws_cloudwatch_metric_alarm" "events_errors" {
  count = var.enable_eventbridge && var.enable_monitoring ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-events-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "Errors"
  namespace          = "AWS/Lambda"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.error_rate_threshold
  alarm_description  = "This metric monitors EventBridge event processing errors"

  dimensions = {
    FunctionName = aws_lambda_function.events[0].function_name
  }

  alarm_actions = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions    = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []

  tags = merge(var.tags, {
    Name        = "${var.project_name}-events-alarm"
    Environment = var.environment
  })
}

# CloudWatch Metric Alarm for Failed Invocations
resource "aws_cloudwatch_metric_alarm" "events_failed" {
  count = var.enable_eventbridge && var.enable_monitoring ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-events-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "FailedInvocations"
  namespace          = "AWS/Events"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "This metric monitors failed EventBridge rule invocations"

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.main[0].name
  }

  alarm_actions = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions    = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []

  tags = merge(var.tags, {
    Name        = "${var.project_name}-events-failed-alarm"
    Environment = var.environment
  })
}

# CloudWatch Metric Alarm for Throttled Events
resource "aws_cloudwatch_metric_alarm" "events_throttled" {
  count = var.enable_eventbridge && var.enable_monitoring ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-events-throttled"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "ThrottledRules"
  namespace          = "AWS/Events"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "This metric monitors throttled EventBridge rules"

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.main[0].name
  }

  alarm_actions = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions    = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []

  tags = merge(var.tags, {
    Name        = "${var.project_name}-events-throttled-alarm"
    Environment = var.environment
  })
} 