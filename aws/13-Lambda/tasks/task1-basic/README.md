# Task 1: Basic Lambda Setup

This task implements a basic AWS Lambda function setup with essential configurations and monitoring. You'll learn how to create and configure Lambda functions with proper IAM roles, environment variables, and basic monitoring.

## Architecture Overview

```
┌──────────────┐     ┌──────────────┐
│              │     │              │
│  CloudWatch  │◄────┤    Lambda    │
│    Logs      │     │   Function   │
│              │     │              │
└──────────────┘     └──────────────┘
                           ▲
                           │
                     ┌──────────────┐
                     │              │
                     │  IAM Role    │
                     │              │
                     └──────────────┘
```

## Components

1. **Lambda Function**
   - Basic Python function
   - Environment variables
   - Memory and timeout settings
   - Basic error handling

2. **IAM Role**
   - Execution role
   - Basic permissions
   - CloudWatch Logs access

3. **Monitoring**
   - CloudWatch Logs integration
   - Basic metrics
   - Error tracking

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version >= 1.0.0)
- Basic Python knowledge
- Understanding of IAM concepts

## Implementation Steps

1. Create the Lambda function using `main.tf`
2. Configure IAM roles and policies using `iam.tf`
3. Set up environment variables and basic configuration
4. Implement monitoring and logging
5. Test the function using provided test events

## Files

- `main.tf` - Primary Lambda function configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `iam.tf` - IAM roles and policies
- `src/` - Function source code
  - `handler.py` - Main Lambda handler
  - `requirements.txt` - Python dependencies

## Function Code

The basic Lambda function will:
1. Process incoming events
2. Perform basic validation
3. Log execution details
4. Return formatted response

Example handler:
```python
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    logger.info(f"Processing event: {event}")
    
    try:
        # Process event
        result = process_event(event)
        
        # Return success response
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Success',
                'data': result
            })
        }
    except Exception as e:
        logger.error(f"Error processing event: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Error',
                'error': str(e)
            })
        }
```

## Validation Steps

1. **Deploy Function**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

2. **Test Function**
   ```bash
   aws lambda invoke \
     --function-name basic-lambda \
     --payload '{"test": "event"}' \
     response.json
   ```

3. **Check Logs**
   ```bash
   aws logs get-log-events \
     --log-group-name /aws/lambda/basic-lambda \
     --log-stream-name <latest-stream>
   ```

## Expected Outcome

- Successfully deployed Lambda function
- Proper IAM role configuration
- CloudWatch Logs integration
- Basic error handling
- Monitoring setup

## Common Issues and Solutions

1. **Deployment Issues**
   - Check IAM permissions
   - Verify function code
   - Check deployment package size

2. **Execution Issues**
   - Review CloudWatch Logs
   - Check timeout settings
   - Verify memory allocation

3. **Permission Issues**
   - Verify IAM role
   - Check policy attachments
   - Review CloudWatch permissions

## Next Steps

After completing this task, you should:
1. Understand basic Lambda configuration
2. Know how to deploy functions
3. Be able to monitor execution
4. Handle basic errors
5. Be ready for Task 2 (Event Sources and Triggers) 