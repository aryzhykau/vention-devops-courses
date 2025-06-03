# Task 1: Basic SNS-SQS Setup

This task implements a basic SNS-SQS setup with standard queues and topics. You'll learn how to create and configure SNS topics, SQS queues, and set up basic integrations between them.

## Architecture Overview

```
                                    ┌──────────────┐
                                    │              │
                              ┌────►│   Queue 1    │
┌──────────────┐             │     │              │
│              │             │     └──────────────┘
│  SNS Topic   ├─────────────┤
│              │             │     ┌──────────────┐
└──────────────┘             │     │              │
                             └────►│   Queue 2    │
                                   │              │
                                   └──────────────┘
```

## Components

1. **SNS Topic**
   - Standard SNS topic for message publishing
   - Basic access policy
   - CloudWatch integration

2. **SQS Queues**
   - Two standard SQS queues
   - Basic queue policies
   - Dead letter queue configuration

3. **Integrations**
   - SNS to SQS subscriptions
   - Basic message filtering
   - CloudWatch metrics and alarms

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version >= 1.0.0)
- Basic understanding of messaging concepts

## Implementation Steps

1. Create the SNS topic and SQS queues using `main.tf`
2. Configure the necessary IAM permissions using `iam.tf`
3. Set up CloudWatch monitoring using the provided configurations
4. Test the setup using the validation steps below

## Files

- `main.tf` - Primary resource definitions
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `iam.tf` - IAM roles and policies

## Validation Steps

1. **Publish a Message**
   ```bash
   aws sns publish \
     --topic-arn <TOPIC_ARN> \
     --message "Test message" \
     --region <REGION>
   ```

2. **Check Queue Reception**
   ```bash
   aws sqs receive-message \
     --queue-url <QUEUE_URL> \
     --region <REGION>
   ```

3. **Verify CloudWatch Metrics**
   - Check NumberOfMessagesPublished in SNS
   - Check ApproximateNumberOfMessagesVisible in SQS

## Expected Outcome

- Successfully created SNS topic and SQS queues
- Messages flow from SNS to both SQS queues
- CloudWatch metrics show successful message delivery
- Basic monitoring alarms are active

## Common Issues and Solutions

1. **Message Delivery Issues**
   - Check IAM permissions
   - Verify queue policies
   - Confirm subscription status

2. **Monitoring Issues**
   - Verify CloudWatch role permissions
   - Check metric namespace
   - Confirm alarm configurations

## Next Steps

After completing this task, you should:
1. Understand basic SNS-SQS integration
2. Be able to monitor message flow
3. Know how to troubleshoot basic issues
4. Be ready to move to Task 2 for advanced features 