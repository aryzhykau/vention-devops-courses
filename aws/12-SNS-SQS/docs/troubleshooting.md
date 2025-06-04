# SNS-SQS Troubleshooting Guide

## Common Issues and Solutions

### 1. Messages Not Being Delivered

#### Symptoms
- Messages published but not received by subscribers
- No messages appearing in SQS queue

#### Possible Causes and Solutions
1. **IAM Permissions**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [{
       "Effect": "Allow",
       "Action": [
         "sqs:ReceiveMessage",
         "sqs:DeleteMessage",
         "sqs:GetQueueAttributes"
       ],
       "Resource": "QUEUE_ARN"
     }]
   }
   ```
   - Verify SNS topic policy allows publishing
   - Check SQS queue policy allows receiving
   - Validate IAM roles and permissions

2. **Queue Visibility Timeout**
   - Message might be in flight
   - Adjust visibility timeout if processing takes longer
   - Check CloudWatch metric: ApproximateAgeOfOldestMessage

3. **Subscription Confirmation**
   - Verify subscription status is "confirmed"
   - Check subscription attributes
   - Manually confirm if needed

### 2. Message Processing Issues

#### Symptoms
- Messages repeatedly processed
- Messages stuck in queue
- High DLQ count

#### Solutions
1. **Visibility Timeout Adjustment**
   ```hcl
   resource "aws_sqs_queue" "main" {
     visibility_timeout_seconds = 300  # Adjust based on processing time
   }
   ```

2. **Dead Letter Queue Setup**
   ```hcl
   resource "aws_sqs_queue" "main" {
     redrive_policy = jsonencode({
       deadLetterTargetArn = aws_sqs_queue.dlq.arn
       maxReceiveCount     = 3
     })
   }
   ```

3. **Monitor Processing Metrics**
   - Set up CloudWatch alarms
   - Track processing success/failure rates
   - Monitor queue depth

### 3. Performance Issues

#### Symptoms
- High latency
- Message backlog
- Throttling errors

#### Solutions
1. **Long Polling**
   ```hcl
   resource "aws_sqs_queue" "main" {
     receive_wait_time_seconds = 20
   }
   ```

2. **Batch Processing**
   - Use batch APIs where possible
   - Implement proper concurrency
   - Scale consumers appropriately

3. **Queue Scaling**
   - Monitor queue metrics
   - Implement auto-scaling for consumers
   - Consider multiple queues for different priorities

### 4. FIFO Queue Issues

#### Symptoms
- Messages out of order
- Duplicate messages
- Deduplication not working

#### Solutions
1. **Message Group ID**
   ```python
   # Ensure proper message group ID usage
   message_group_id = "order_123"  # For related messages
   ```

2. **Deduplication ID**
   ```python
   # Implement proper deduplication
   deduplication_id = "unique_transaction_id"
   ```

3. **Content-Based Deduplication**
   ```hcl
   resource "aws_sqs_queue" "fifo" {
     fifo_queue                  = true
     content_based_deduplication = true
   }
   ```

### 5. Security Issues

#### Symptoms
- Access denied errors
- Encryption failures
- Cross-account access issues

#### Solutions
1. **KMS Encryption**
   ```hcl
   resource "aws_sqs_queue" "encrypted" {
     kms_master_key_id = "alias/aws/sqs"
     kms_data_key_reuse_period_seconds = 300
   }
   ```

2. **Cross-Account Access**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [{
       "Effect": "Allow",
       "Principal": {
         "AWS": "arn:aws:iam::ACCOUNT-ID:root"
       },
       "Action": "sqs:*",
       "Resource": "QUEUE_ARN"
     }]
   }
   ```

3. **VPC Endpoint Configuration**
   ```hcl
   resource "aws_vpc_endpoint" "sqs" {
     vpc_id       = aws_vpc.main.id
     service_name = "com.amazonaws.region.sqs"
   }
   ```

## Monitoring and Debugging

### CloudWatch Metrics to Monitor
1. **Queue Metrics**
   - ApproximateNumberOfMessagesVisible
   - ApproximateNumberOfMessagesNotVisible
   - ApproximateAgeOfOldestMessage

2. **Processing Metrics**
   - NumberOfMessagesReceived
   - NumberOfMessagesDeleted
   - NumberOfEmptyReceives

3. **DLQ Metrics**
   - ApproximateNumberOfMessagesVisible in DLQ
   - Age of messages in DLQ

### Logging Best Practices
1. **Enable CloudWatch Logs**
   - Log message IDs
   - Track processing times
   - Record errors with context

2. **Implement Tracing**
   - Use AWS X-Ray
   - Track message flow
   - Monitor end-to-end latency

## Prevention Strategies

1. **Implementation Checklist**
   - Proper IAM permissions
   - DLQ configuration
   - Monitoring setup
   - Error handling

2. **Testing Procedures**
   - Load testing
   - Failure scenarios
   - Recovery procedures

3. **Documentation**
   - Architecture diagrams
   - Configuration details
   - Troubleshooting procedures 