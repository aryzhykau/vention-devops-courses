# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# SNS Topic
resource "aws_sns_topic" "main" {
  name = "${var.project_name}-${var.environment}-topic"

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-topic"
    Environment = var.environment
  })
}

# First SQS Queue
resource "aws_sqs_queue" "queue1" {
  name = "${var.project_name}-${var.environment}-queue1"

  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds = var.message_retention_seconds
  delay_seconds            = var.delay_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds

  # DLQ Configuration
  redrive_policy = var.enable_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq1[0].arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  # Server-side encryption
  sqs_managed_sse_enabled = var.enable_encryption

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-queue1"
    Environment = var.environment
  })
}

# Second SQS Queue
resource "aws_sqs_queue" "queue2" {
  name = "${var.project_name}-${var.environment}-queue2"

  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds = var.message_retention_seconds
  delay_seconds            = var.delay_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds

  # DLQ Configuration
  redrive_policy = var.enable_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq2[0].arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  # Server-side encryption
  sqs_managed_sse_enabled = var.enable_encryption

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-queue2"
    Environment = var.environment
  })
}

# DLQ for Queue 1
resource "aws_sqs_queue" "dlq1" {
  count = var.enable_dlq ? 1 : 0

  name = "${var.project_name}-${var.environment}-queue1-dlq"

  message_retention_seconds = var.message_retention_seconds
  sqs_managed_sse_enabled  = var.enable_encryption

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-queue1-dlq"
    Environment = var.environment
  })
}

# DLQ for Queue 2
resource "aws_sqs_queue" "dlq2" {
  count = var.enable_dlq ? 1 : 0

  name = "${var.project_name}-${var.environment}-queue2-dlq"

  message_retention_seconds = var.message_retention_seconds
  sqs_managed_sse_enabled  = var.enable_encryption

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-queue2-dlq"
    Environment = var.environment
  })
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "main" {
  arn = aws_sns_topic.main.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSNSPublish"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.main.arn
        Condition = {
          StringEquals = {
            "AWS:SourceOwner" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# Queue Policies
resource "aws_sqs_queue_policy" "queue1" {
  queue_url = aws_sqs_queue.queue1.url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSNSMessage"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "SQS:SendMessage"
        Resource = aws_sqs_queue.queue1.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.main.arn
          }
        }
      }
    ]
  })
}

resource "aws_sqs_queue_policy" "queue2" {
  queue_url = aws_sqs_queue.queue2.url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSNSMessage"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "SQS:SendMessage"
        Resource = aws_sqs_queue.queue2.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.main.arn
          }
        }
      }
    ]
  })
}

# SNS Topic Subscriptions
resource "aws_sns_topic_subscription" "queue1" {
  topic_arn = aws_sns_topic.main.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.queue1.arn
}

resource "aws_sns_topic_subscription" "queue2" {
  topic_arn = aws_sns_topic.main.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.queue2.arn
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "queue1_depth" {
  count = var.enable_cloudwatch_alerts ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-queue1-depth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "ApproximateNumberOfMessagesVisible"
  namespace          = "AWS/SQS"
  period             = "300"
  statistic          = "Average"
  threshold          = "100"
  alarm_description  = "This metric monitors queue 1 depth"
  alarm_actions      = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    QueueName = aws_sqs_queue.queue1.name
  }
}

resource "aws_cloudwatch_metric_alarm" "queue2_depth" {
  count = var.enable_cloudwatch_alerts ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-queue2-depth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "ApproximateNumberOfMessagesVisible"
  namespace          = "AWS/SQS"
  period             = "300"
  statistic          = "Average"
  threshold          = "100"
  alarm_description  = "This metric monitors queue 2 depth"
  alarm_actions      = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    QueueName = aws_sqs_queue.queue2.name
  }
}

# DLQ Alarms
resource "aws_cloudwatch_metric_alarm" "dlq1_depth" {
  count = var.enable_cloudwatch_alerts && var.enable_dlq ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-dlq1-depth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "ApproximateNumberOfMessagesVisible"
  namespace          = "AWS/SQS"
  period             = "300"
  statistic          = "Average"
  threshold          = "0"
  alarm_description  = "This metric monitors DLQ 1 depth"
  alarm_actions      = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    QueueName = aws_sqs_queue.dlq1[0].name
  }
}

resource "aws_cloudwatch_metric_alarm" "dlq2_depth" {
  count = var.enable_cloudwatch_alerts && var.enable_dlq ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-dlq2-depth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "ApproximateNumberOfMessagesVisible"
  namespace          = "AWS/SQS"
  period             = "300"
  statistic          = "Average"
  threshold          = "0"
  alarm_description  = "This metric monitors DLQ 2 depth"
  alarm_actions      = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    QueueName = aws_sqs_queue.dlq2[0].name
  }
}

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  count = var.enable_cloudwatch_alerts && var.alert_email != "" ? 1 : 0

  name = "${var.project_name}-${var.environment}-alerts"

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-alerts"
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

# Data Sources
data "aws_caller_identity" "current" {} 