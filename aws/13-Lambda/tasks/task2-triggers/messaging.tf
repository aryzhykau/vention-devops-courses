# SNS Topic
resource "aws_sns_topic" "main" {
  count = var.enable_sns ? 1 : 0

  name = "${var.project_name}-${var.environment}-topic"

  kms_master_key_id = "alias/aws/sns"

  tags = merge(var.tags, {
    Name        = "${var.project_name}-topic"
    Environment = var.environment
  })
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "main" {
  count = var.enable_sns ? 1 : 0

  arn = aws_sns_topic.main[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublishFromAuthorizedAccounts"
        Effect    = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = "SNS:Publish"
        Resource = aws_sns_topic.main[0].arn
        Condition = {
          StringEquals = {
            "AWS:SourceOwner" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# SQS Queue
resource "aws_sqs_queue" "main" {
  count = var.enable_sqs ? 1 : 0

  name = "${var.project_name}-${var.environment}-queue"

  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  max_message_size          = 262144  # 256 KB
  delay_seconds             = 0

  # Enable server-side encryption
  sqs_managed_sse_enabled = true

  # Enable dead-letter queue if configured
  redrive_policy = var.enable_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = 3
  }) : null

  tags = merge(var.tags, {
    Name        = "${var.project_name}-queue"
    Environment = var.environment
  })
}

# Dead Letter Queue
resource "aws_sqs_queue" "dlq" {
  count = var.enable_sqs && var.enable_dlq ? 1 : 0

  name = "${var.project_name}-${var.environment}-dlq"

  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds * 2  # Double the retention for DLQ
  max_message_size          = 262144  # 256 KB
  delay_seconds             = 0

  # Enable server-side encryption
  sqs_managed_sse_enabled = true

  tags = merge(var.tags, {
    Name        = "${var.project_name}-dlq"
    Environment = var.environment
  })
}

# SQS Queue Policy
resource "aws_sqs_queue_policy" "main" {
  count = var.enable_sqs ? 1 : 0

  queue_url = aws_sqs_queue.main[0].url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSNSPublish"
        Effect    = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.main[0].arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = var.enable_sns ? aws_sns_topic.main[0].arn : ""
          }
        }
      }
    ]
  })
}

# DLQ Policy
resource "aws_sqs_queue_policy" "dlq" {
  count = var.enable_sqs && var.enable_dlq ? 1 : 0

  queue_url = aws_sqs_queue.dlq[0].url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSQSRedrivePolicy"
        Effect    = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.account_id
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.dlq[0].arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sqs_queue.main[0].arn
          }
        }
      }
    ]
  })
}

# SNS Topic Subscription to SQS
resource "aws_sns_topic_subscription" "sns_to_sqs" {
  count = var.enable_sns && var.enable_sqs ? 1 : 0

  topic_arn = aws_sns_topic.main[0].arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.main[0].arn

  raw_message_delivery = true
}

# CloudWatch Log Group for Queue Processing
resource "aws_cloudwatch_log_group" "queue" {
  count = var.enable_sqs ? 1 : 0

  name              = "/aws/lambda/${var.project_name}-${var.environment}-queue"
  retention_in_days = var.lambda_log_retention_days

  tags = merge(var.tags, {
    Name        = "${var.project_name}-queue-logs"
    Environment = var.environment
  })
}

# CloudWatch Metric Alarm for Queue Errors
resource "aws_cloudwatch_metric_alarm" "queue_errors" {
  count = var.enable_sqs && var.enable_monitoring ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-queue-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "Errors"
  namespace          = "AWS/Lambda"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.error_rate_threshold
  alarm_description  = "This metric monitors queue processing errors"

  dimensions = {
    FunctionName = aws_lambda_function.queue[0].function_name
  }

  alarm_actions = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions    = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []

  tags = merge(var.tags, {
    Name        = "${var.project_name}-queue-alarm"
    Environment = var.environment
  })
}

# CloudWatch Metric Alarm for Queue Age
resource "aws_cloudwatch_metric_alarm" "queue_age" {
  count = var.enable_sqs && var.enable_monitoring ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-queue-age"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "ApproximateAgeOfOldestMessage"
  namespace          = "AWS/SQS"
  period             = "300"
  statistic          = "Maximum"
  threshold          = "3600"  # 1 hour
  alarm_description  = "This metric monitors the age of the oldest message in the queue"

  dimensions = {
    QueueName = aws_sqs_queue.main[0].name
  }

  alarm_actions = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions    = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []

  tags = merge(var.tags, {
    Name        = "${var.project_name}-queue-age-alarm"
    Environment = var.environment
  })
}

# CloudWatch Metric Alarm for DLQ Messages
resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  count = var.enable_sqs && var.enable_dlq && var.enable_monitoring ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-dlq-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "ApproximateNumberOfMessagesVisible"
  namespace          = "AWS/SQS"
  period             = "300"
  statistic          = "Maximum"
  threshold          = "0"
  alarm_description  = "This metric monitors the number of messages in the DLQ"

  dimensions = {
    QueueName = aws_sqs_queue.dlq[0].name
  }

  alarm_actions = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions    = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []

  tags = merge(var.tags, {
    Name        = "${var.project_name}-dlq-alarm"
    Environment = var.environment
  })
} 