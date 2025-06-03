# SNS-SQS Common Patterns Guide

## 1. Fan-out Pattern
### Description
One message published to an SNS topic is delivered to multiple SQS queues, allowing parallel processing.

### Implementation
```hcl
# SNS Topic
resource "aws_sns_topic" "main" {}

# Multiple SQS Queues
resource "aws_sqs_queue" "queue1" {}
resource "aws_sqs_queue" "queue2" {}

# Subscriptions
resource "aws_sns_topic_subscription" "sub1" {
  topic_arn = aws_sns_topic.main.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.queue1.arn
}
```

### Use Cases
- Event notifications to multiple systems
- Parallel processing of events
- Decoupled microservices

## 2. Dead Letter Queue Pattern
### Description
Messages that cannot be processed are moved to a separate queue for analysis and retry.

### Implementation
```hcl
# Main Queue
resource "aws_sqs_queue" "main" {
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })
}

# Dead Letter Queue
resource "aws_sqs_queue" "dlq" {}
```

### Use Cases
- Error handling
- Message retry logic
- Debugging failed processing

## 3. Priority Queue Pattern
### Description
Multiple queues with different priorities for message processing.

### Implementation
```hcl
# High Priority Queue
resource "aws_sqs_queue" "high_priority" {
  delay_seconds = 0
}

# Low Priority Queue
resource "aws_sqs_queue" "low_priority" {
  delay_seconds = 300
}
```

### Use Cases
- Critical vs non-critical messages
- Resource allocation optimization
- SLA management

## 4. Message Filtering Pattern
### Description
Filter messages at the subscription level to receive only relevant messages.

### Implementation
```hcl
resource "aws_sns_topic_subscription" "filtered" {
  topic_arn = aws_sns_topic.main.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.queue.arn
  
  filter_policy = jsonencode({
    event_type = ["order_created", "order_updated"]
    priority   = ["high"]
  })
}
```

### Use Cases
- Targeted message delivery
- Reduced processing overhead
- Event-based routing

## 5. FIFO Pattern
### Description
Guaranteed ordering and exactly-once processing of messages.

### Implementation
```hcl
# FIFO Topic
resource "aws_sns_topic" "fifo" {
  name                        = "my-topic.fifo"
  fifo_topic                 = true
  content_based_deduplication = true
}

# FIFO Queue
resource "aws_sqs_queue" "fifo" {
  name                        = "my-queue.fifo"
  fifo_queue                 = true
  content_based_deduplication = true
}
```

### Use Cases
- Order processing
- Financial transactions
- Sequential workflows

## 6. Cross-Account Pattern
### Description
SNS topics in one account publishing to SQS queues in another account.

### Implementation
```hcl
# Queue Policy
resource "aws_sqs_queue_policy" "cross_account" {
  queue_url = aws_sqs_queue.queue.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::ACCOUNT-ID:root"
      }
      Action   = "sqs:SendMessage"
      Resource = aws_sqs_queue.queue.arn
    }]
  })
}
```

### Use Cases
- Multi-account architectures
- Organizational message routing
- Service isolation

## 7. Delay Queue Pattern
### Description
Messages are intentionally delayed before becoming available for processing.

### Implementation
```hcl
resource "aws_sqs_queue" "delayed" {
  delay_seconds = 900  # 15 minutes
}
```

### Use Cases
- Scheduled processing
- Rate limiting
- Cooldown periods

## Best Practices for Pattern Implementation
1. **Error Handling**
   - Implement proper error handling
   - Use DLQ where appropriate
   - Monitor failed deliveries

2. **Monitoring**
   - Set up relevant CloudWatch metrics
   - Configure appropriate alarms
   - Track pattern-specific metrics

3. **Security**
   - Use appropriate IAM policies
   - Implement encryption
   - Follow least privilege principle 