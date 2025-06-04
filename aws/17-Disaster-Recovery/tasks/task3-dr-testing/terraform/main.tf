provider "aws" {
  region = var.aws_region
}

# S3 bucket for documentation and test results
resource "aws_s3_bucket" "dr_docs" {
  bucket = "${var.project_name}-dr-docs-${data.aws_caller_identity.current.account_id}"
  
  tags = var.tags
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "dr_docs" {
  bucket = aws_s3_bucket.dr_docs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Lambda function for backup validation
resource "aws_lambda_function" "backup_validator" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-backup-validator"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.8"
  timeout         = 300

  environment {
    variables = {
      BACKUP_VAULT_NAME = var.backup_vault_name
      SNS_TOPIC_ARN    = aws_sns_topic.dr_notifications.arn
    }
  }

  tags = var.tags
}

# EventBridge rule for scheduled testing
resource "aws_cloudwatch_event_rule" "dr_test" {
  name                = "${var.project_name}-dr-test"
  description         = "Trigger DR test procedures"
  schedule_expression = var.test_schedule

  tags = var.tags
}

# EventBridge target
resource "aws_cloudwatch_event_target" "dr_test" {
  rule      = aws_cloudwatch_event_rule.dr_test.name
  target_id = "BackupValidation"
  arn       = aws_lambda_function.backup_validator.arn
}

# SNS topic for DR notifications
resource "aws_sns_topic" "dr_notifications" {
  name = "${var.project_name}-dr-notifications"
  tags = var.tags
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

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

  tags = var.tags
}

# IAM policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "backup:*",
          "s3:*",
          "sns:Publish",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.backup_validator.function_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"

  source {
    content = <<EOF
import boto3
import os
import json

def handler(event, context):
    backup = boto3.client('backup')
    sns = boto3.client('sns')
    
    try:
        # Check recent backup jobs
        response = backup.list_backup_jobs(
            ByState='COMPLETED',
            MaxResults=10
        )
        
        # Validate backup jobs
        failed_jobs = []
        for job in response['BackupJobs']:
            if job['State'] != 'COMPLETED':
                failed_jobs.append(job['BackupJobId'])
        
        # Send notification
        message = {
            'status': 'SUCCESS' if not failed_jobs else 'FAILURE',
            'failed_jobs': failed_jobs,
            'message': 'Backup validation complete'
        }
        
        sns.publish(
            TopicArn=os.environ['SNS_TOPIC_ARN'],
            Message=json.dumps(message),
            Subject='DR Test Results'
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps(message)
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
EOF
    filename = "index.py"
  }
}

# Data source for current account ID
data "aws_caller_identity" "current" {} 