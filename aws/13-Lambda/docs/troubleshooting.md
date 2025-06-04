# AWS Lambda Troubleshooting Guide

## Common Issues and Solutions

### 1. Execution Issues

#### Timeout Errors
**Symptoms:**
- Function execution exceeds configured timeout
- Task incomplete
- Timeout errors in logs

**Solutions:**
1. **Increase Timeout**
```hcl
resource "aws_lambda_function" "main" {
  timeout = 300  # 5 minutes
}
```

2. **Optimize Code**
```python
# Bad Practice
def handler(event, context):
    for item in large_list:
        process_item(item)  # Sequential processing

# Good Practice
def handler(event, context):
    # Parallel processing or batch operations
    with concurrent.futures.ThreadPoolExecutor() as executor:
        executor.map(process_item, large_list)
```

3. **Monitor Duration**
```python
def handler(event, context):
    start_time = time.time()
    # Set threshold for early termination
    timeout_threshold = context.get_remaining_time_in_millis() - 1000
    
    while processing:
        if (time.time() - start_time) * 1000 > timeout_threshold:
            # Save state and exit gracefully
            break
```

### 2. Memory Issues

#### Out of Memory
**Symptoms:**
- Process killed
- Memory exceeded errors
- Performance degradation

**Solutions:**
1. **Increase Memory**
```hcl
resource "aws_lambda_function" "main" {
  memory_size = 1024  # 1GB
}
```

2. **Memory Monitoring**
```python
import psutil
import logging

logger = logging.getLogger()

def monitor_memory():
    process = psutil.Process()
    memory_info = process.memory_info()
    logger.info(f"Memory usage: {memory_info.rss / 1024 / 1024} MB")
```

3. **Memory Optimization**
```python
# Bad Practice
def handler(event, context):
    large_data = load_entire_dataset()  # Loads everything into memory

# Good Practice
def handler(event, context):
    for chunk in load_data_in_chunks():  # Stream processing
        process_chunk(chunk)
```

### 3. Permissions Issues

#### Access Denied
**Symptoms:**
- Access denied errors
- Service integration failures
- Permission-related exceptions

**Solutions:**
1. **IAM Role Configuration**
```hcl
resource "aws_iam_role_policy" "lambda_policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "dynamodb:Query"
        ]
        Resource = [
          aws_s3_bucket.data.arn,
          aws_dynamodb_table.main.arn
        ]
      }
    ]
  })
}
```

2. **Resource Policy**
```hcl
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.trigger.arn
}
```

3. **VPC Access**
```hcl
resource "aws_lambda_function" "main" {
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }
}
```

### 4. Cold Start Issues

#### High Latency
**Symptoms:**
- Intermittent high response times
- Initial request delays
- Inconsistent performance

**Solutions:**
1. **Provisioned Concurrency**
```hcl
resource "aws_lambda_provisioned_concurrency_config" "main" {
  function_name                     = aws_lambda_function.main.function_name
  provisioned_concurrent_executions = 10
  qualifier                        = aws_lambda_alias.main.name
}
```

2. **Code Optimization**
```python
# Bad Practice - Initialize in handler
def handler(event, context):
    client = boto3.client('s3')  # Cold start overhead
    
# Good Practice - Initialize outside handler
client = boto3.client('s3')  # Reused across invocations

def handler(event, context):
    # Use existing client
```

3. **Dependency Management**
```python
# Use Lambda Layers for dependencies
resource "aws_lambda_layer_version" "deps" {
  filename   = "dependencies.zip"
  layer_name = "common_dependencies"
}
```

### 5. Network Issues

#### VPC Connectivity
**Symptoms:**
- Timeouts accessing external services
- Network-related errors
- DNS resolution failures

**Solutions:**
1. **VPC Configuration**
```hcl
# NAT Gateway for internet access
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

# VPC Endpoints for AWS services
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"
}
```

2. **Security Group Rules**
```hcl
resource "aws_security_group" "lambda" {
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

3. **DNS Configuration**
```hcl
resource "aws_vpc" "main" {
  enable_dns_hostnames = true
  enable_dns_support   = true
}
```

### 6. Monitoring and Debugging

#### Error Investigation
**Tools and Techniques:**
1. **CloudWatch Logs**
```python
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    try:
        logger.info(f"Processing event: {event}")
        result = process_event(event)
        logger.info(f"Success: {result}")
        return result
    except Exception as e:
        logger.error(f"Error: {str(e)}", exc_info=True)
        raise
```

2. **X-Ray Tracing**
```python
from aws_xray_sdk.core import patch_all
patch_all()

@xray_recorder.capture('process_event')
def process_event(event):
    # Function code
```

3. **Metrics and Alarms**
```hcl
resource "aws_cloudwatch_metric_alarm" "errors" {
  alarm_name          = "${var.function_name}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "Errors"
  namespace          = "AWS/Lambda"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
}
```

### 7. Deployment Issues

#### Failed Deployments
**Solutions:**
1. **Version Management**
```hcl
resource "aws_lambda_alias" "main" {
  name             = "prod"
  function_name    = aws_lambda_function.main.function_name
  function_version = aws_lambda_function.main.version
}
```

2. **Rollback Procedure**
```hcl
resource "aws_lambda_alias" "main" {
  name             = "prod"
  function_name    = aws_lambda_function.main.function_name
  function_version = "1"  # Rollback to specific version
}
```

3. **Deployment Validation**
```python
def test_function():
    client = boto3.client('lambda')
    response = client.invoke(
        FunctionName='function_name',
        Payload=json.dumps({'test': True})
    )
    assert response['StatusCode'] == 200
``` 