# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# DynamoDB Table
resource "aws_dynamodb_table" "main" {
  name           = "${var.project_name}-${var.environment}-${var.table_name}"
  billing_mode   = var.billing_mode
  hash_key       = "UserId"
  
  # Provisioned capacity (if not using PAY_PER_REQUEST)
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  # Primary key attribute
  attribute {
    name = "UserId"
    type = "S"
  }

  # Enable point-in-time recovery
  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  # Enable server-side encryption
  server_side_encryption {
    enabled = var.enable_server_side_encryption
  }

  # Enable TTL if configured
  dynamic "ttl" {
    for_each = var.enable_ttl ? [1] : []
    content {
      enabled        = true
      attribute_name = var.ttl_attribute
    }
  }

  # Tags
  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.table_name}"
    Environment = var.environment
  })
}

# Auto Scaling Configuration (if enabled and using PROVISIONED billing mode)
resource "aws_appautoscaling_target" "read_target" {
  count = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? 1 : 0

  max_capacity       = var.max_read_capacity
  min_capacity       = var.min_read_capacity
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_target" "write_target" {
  count = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? 1 : 0

  max_capacity       = var.max_write_capacity
  min_capacity       = var.min_write_capacity
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "read_policy" {
  count = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? 1 : 0

  name               = "${var.project_name}-${var.environment}-read-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.read_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.read_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = var.target_utilization
  }
}

resource "aws_appautoscaling_policy" "write_policy" {
  count = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? 1 : 0

  name               = "${var.project_name}-${var.environment}-write-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.write_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.write_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = var.target_utilization
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "read_throttle" {
  count = var.enable_monitoring ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-read-throttle"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "ReadThrottleEvents"
  namespace          = "AWS/DynamoDB"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "DynamoDB read throttle events"
  alarm_actions      = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    TableName = aws_dynamodb_table.main.name
  }
}

resource "aws_cloudwatch_metric_alarm" "write_throttle" {
  count = var.enable_monitoring ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-write-throttle"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "WriteThrottleEvents"
  namespace          = "AWS/DynamoDB"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "DynamoDB write throttle events"
  alarm_actions      = var.alert_email != "" ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    TableName = aws_dynamodb_table.main.name
  }
}

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  count = var.enable_monitoring && var.alert_email != "" ? 1 : 0

  name = "${var.project_name}-${var.environment}-alerts"

  tags = merge(var.tags, {
    Name        = "${var.project_name}-alerts"
    Environment = var.environment
  })
}

resource "aws_sns_topic_subscription" "alerts_email" {
  count = var.enable_monitoring && var.alert_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Lambda Trigger (if enabled)
resource "aws_lambda_function" "dynamodb_trigger" {
  count = var.enable_lambda_trigger ? 1 : 0

  filename         = "${path.module}/src/lambda_function.zip"
  function_name    = "${var.project_name}-${var.environment}-${var.lambda_function_name}"
  role            = aws_iam_role.lambda_role[0].arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 30

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.main.name
      ENVIRONMENT = var.environment
    }
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-lambda"
    Environment = var.environment
  })
} 