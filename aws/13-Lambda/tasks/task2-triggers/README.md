# Task 2: Event Sources and Triggers

This task implements various event sources and triggers for AWS Lambda functions. You'll learn how to integrate Lambda with different AWS services and create event-driven architectures.

## Architecture Overview

```
                     ┌──────────────┐
                     │              │
                     │ API Gateway  │
                     │              │
                     └──────┬───────┘
                            │
┌──────────────┐    ┌──────┴───────┐    ┌──────────────┐
│              │    │              │    │              │
│     S3       ├───►│    Lambda    │◄───┤ EventBridge  │
│              │    │              │    │              │
└──────────────┘    └──────┬───────┘    └──────────────┘
                           │
                    ┌──────┴───────┐
                    │              │
                    │   SNS/SQS    │
                    │              │
                    └──────────────┘
```

## Components

1. **API Gateway Integration**
   - REST API configuration
   - HTTP API setup
   - Request/response mapping
   - CORS configuration

2. **S3 Event Triggers**
   - Bucket notifications
   - Event filtering
   - Object operations
   - Batch processing

3. **EventBridge (CloudWatch Events)**
   - Scheduled events
   - Custom event patterns
   - Cross-account events
   - Event routing

4. **SNS/SQS Integration**
   - Queue processing
   - Topic subscriptions
   - Dead letter queues
   - Message filtering

## Prerequisites

- Completed Task 1 (Basic Lambda Setup)
- AWS CLI configured
- Basic understanding of AWS event sources
- Knowledge of API design principles

## Implementation Steps

1. **API Gateway Setup**
   - Create REST/HTTP API
   - Configure integration
   - Set up methods and resources
   - Enable logging and monitoring

2. **S3 Event Configuration**
   - Create S3 bucket
   - Configure notifications
   - Set up event types
   - Implement file processing

3. **EventBridge Rules**
   - Create event rules
   - Configure targets
   - Set up schedules
   - Implement event patterns

4. **SNS/SQS Integration**
   - Create topics/queues
   - Configure subscriptions
   - Set up DLQ
   - Implement message handling

## Files

- `main.tf` - Primary resource configuration
- `api.tf` - API Gateway configuration
- `s3.tf` - S3 bucket and notifications
- `events.tf` - EventBridge rules
- `messaging.tf` - SNS/SQS resources
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `iam.tf` - IAM roles and policies
- `src/` - Lambda function code
  - `api_handler.py` - API Gateway handler
  - `s3_handler.py` - S3 event handler
  - `event_handler.py` - EventBridge handler
  - `queue_handler.py` - SNS/SQS handler

## Validation Steps

1. **API Gateway Testing**
   ```bash
   # Test API endpoint
   curl -X POST https://<api-id>.execute-api.<region>.amazonaws.com/<stage>/resource \
     -H "Content-Type: application/json" \
     -d '{"test": "data"}'
   ```

2. **S3 Event Testing**
   ```bash
   # Upload file to trigger Lambda
   aws s3 cp test.txt s3://bucket-name/
   ```

3. **EventBridge Testing**
   ```bash
   # Manually trigger rule
   aws events put-events \
     --entries '[{"Source": "test", "DetailType": "test", "Detail": "{}"}]'
   ```

4. **SNS/SQS Testing**
   ```bash
   # Publish message to SNS
   aws sns publish \
     --topic-arn <topic-arn> \
     --message "Test message"
   ```

## Expected Outcomes

1. **API Gateway**
   - Functional REST/HTTP API
   - Proper request handling
   - Error responses
   - CORS support

2. **S3 Events**
   - Automatic event triggering
   - File processing
   - Error handling
   - Event filtering

3. **EventBridge**
   - Scheduled executions
   - Event pattern matching
   - Cross-account routing
   - Error handling

4. **SNS/SQS**
   - Message processing
   - DLQ handling
   - Batch processing
   - Error recovery

## Common Issues and Solutions

1. **API Gateway Issues**
   - CORS configuration
   - Integration response mapping
   - Authorization setup
   - Throttling limits

2. **S3 Event Issues**
   - Permission configuration
   - Event delivery delays
   - Duplicate events
   - Large file handling

3. **EventBridge Issues**
   - Rule configuration
   - Event pattern syntax
   - Target permissions
   - Delivery failures

4. **SNS/SQS Issues**
   - Message visibility
   - DLQ configuration
   - Batch processing errors
   - Queue depth monitoring

## Monitoring and Logging

1. **API Gateway**
   - Access logs
   - Execution logs
   - Latency metrics
   - Error rates

2. **S3 Events**
   - Event delivery metrics
   - Processing success/failure
   - Bucket metrics
   - Lambda invocations

3. **EventBridge**
   - Rule invocations
   - Failed invocations
   - Throttled events
   - Target errors

4. **SNS/SQS**
   - Queue metrics
   - DLQ monitoring
   - Processing metrics
   - Message age

## Next Steps

After completing this task, you should:
1. Understand event-driven architectures
2. Know how to integrate Lambda with AWS services
3. Be able to implement serverless APIs
4. Handle asynchronous processing
5. Be ready for Task 3 (VPC and Network Integration) 