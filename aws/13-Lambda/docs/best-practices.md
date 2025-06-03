# AWS Lambda Best Practices

## Function Design

### 1. Code Organization
- Keep functions focused and small
- Follow single responsibility principle
- Separate business logic from handler
- Use layers for shared code
- Implement proper error handling

### 2. Dependencies
```python
# Good Practice - Minimize dependencies
import json
import boto3  # AWS SDK only

# Bad Practice - Too many dependencies
import pandas
import numpy
import tensorflow  # Heavy dependencies
```

### 3. Handler Pattern
```python
# Good Practice
def handler(event, context):
    try:
        # Input validation
        validate_input(event)
        
        # Business logic
        result = process_event(event)
        
        # Response formatting
        return format_response(result)
    except Exception as e:
        # Error handling
        handle_error(e)

def process_event(event):
    # Separate business logic
    pass
```

## Performance Optimization

### 1. Cold Start Management
- Use Provisioned Concurrency for latency-sensitive applications
- Keep deployment package small
- Initialize SDK clients outside handler
- Use Lambda layers for dependencies

```python
# Good Practice
s3_client = boto3.client('s3')  # Initialize outside handler

def handler(event, context):
    # Use existing client
    response = s3_client.get_object(...)
```

### 2. Memory Configuration
- Test with different memory settings
- Monitor performance metrics
- Use power tuning tool
- Consider cost vs performance

### 3. Timeout Settings
- Set appropriate timeouts
- Consider downstream service latency
- Include buffer for retries
- Monitor execution duration

## Security

### 1. IAM Permissions
```hcl
# Good Practice - Least privilege
resource "aws_iam_role_policy" "lambda_policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.specific_bucket.arn}/*"
        ]
      }
    ]
  })
}
```

### 2. Environment Variables
- Use encryption for sensitive data
- Rotate secrets regularly
- Use AWS Secrets Manager
- Avoid hardcoding credentials

### 3. VPC Security
- Use minimum required subnets
- Implement proper security groups
- Use VPC endpoints where possible
- Monitor network access

## Monitoring and Logging

### 1. CloudWatch Integration
```python
# Good Practice
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    logger.info(f"Processing event: {event}")
    try:
        result = process_event(event)
        logger.info(f"Successfully processed event: {result}")
        return result
    except Exception as e:
        logger.error(f"Error processing event: {str(e)}")
        raise
```

### 2. Metrics
- Monitor key metrics:
  - Duration
  - Error rate
  - Throttles
  - Concurrent executions
- Set up appropriate alarms
- Use custom metrics when needed

### 3. X-Ray Tracing
- Enable X-Ray for complex flows
- Trace downstream calls
- Monitor latency
- Debug issues

## Error Handling

### 1. Retry Strategy
```python
# Good Practice
def handler(event, context):
    max_retries = 3
    retry_count = 0
    
    while retry_count < max_retries:
        try:
            return process_event(event)
        except RetryableError as e:
            retry_count += 1
            if retry_count == max_retries:
                raise
            time.sleep(get_backoff_time(retry_count))
```

### 2. Dead Letter Queues
- Configure DLQ for async invocations
- Monitor DLQ messages
- Implement proper error handling
- Set up alerts for DLQ

### 3. Error Response Format
```python
# Good Practice
def format_error_response(error):
    return {
        'statusCode': error.status_code,
        'body': json.dumps({
            'error': str(error),
            'type': error.__class__.__name__,
            'requestId': context.aws_request_id
        })
    }
```

## Cost Optimization

### 1. Resource Configuration
- Right-size memory allocation
- Optimize timeout settings
- Use provisioned concurrency wisely
- Monitor usage patterns

### 2. Code Efficiency
- Minimize external calls
- Use batch processing
- Implement caching
- Optimize algorithms

### 3. Monitoring Costs
- Track invocation metrics
- Monitor duration trends
- Set up cost alerts
- Regular optimization reviews

## Development and Deployment

### 1. Local Testing
```bash
# Good Practice
# Use SAM for local testing
sam local invoke -e event.json
sam local start-api
```

### 2. CI/CD Pipeline
- Implement automated testing
- Use infrastructure as code
- Version control functions
- Automated deployments

### 3. Version Management
- Use function versions
- Implement aliases
- Test new versions
- Implement rollback procedures

## Integration Patterns

### 1. Event Source Mapping
- Configure proper batch size
- Handle partial batch failures
- Monitor processing delays
- Implement idempotency

### 2. API Integration
- Use proper authorization
- Implement request validation
- Handle rate limiting
- Proper error responses

### 3. Asynchronous Processing
- Use event-driven patterns
- Implement proper DLQ
- Monitor async flows
- Handle timeouts 