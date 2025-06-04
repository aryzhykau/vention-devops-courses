# AWS SNS-SQS Module

This module covers the implementation of Amazon Simple Notification Service (SNS) and Simple Queue Service (SQS) in AWS. The module is structured to provide a comprehensive understanding of message queuing and pub/sub patterns in AWS.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version >= 1.0.0)
- Basic understanding of messaging patterns and event-driven architectures
- Knowledge of AWS IAM and security concepts

## Module Structure

```
12-SNS-SQS/
├── README.md
├── docs/
│   ├── best-practices.md
│   ├── patterns-guide.md
│   └── troubleshooting.md
└── tasks/
    └── task1-basic/         # Basic SNS-SQS Setup
```

## Tasks Overview

1. **Basic SNS-SQS Setup**
   - Creating SNS topics and SQS queues
   - Basic message publishing and consumption
   - Simple subscription and filtering


## Getting Started

Each task directory contains:
- `README.md` with specific instructions
- `main.tf` for primary resources
- `variables.tf` for input variables
- `outputs.tf` for output values
- Additional configuration files as needed

Follow the tasks in order for a structured learning experience.

## Validation

Each task includes validation steps to ensure proper implementation. Use AWS Console and CLI commands to verify your work.

## Documentation

Refer to the `docs/` directory for:
- Best practices in SNS-SQS implementation
- Common messaging patterns and use cases
- Troubleshooting guides and solutions

# Amazon SNS and Amazon SQS

## Overview
Amazon Simple Notification Service (SNS) and Amazon Simple Queue Service (SQS) are messaging services that enable decoupling of microservices, distributed systems, and serverless applications.

## Amazon SNS (Simple Notification Service)

### 1. Core Concepts
- **Topics**
  - Communication channel
  - Publish/Subscribe mechanism
  - Multiple subscribers
  - Message filtering

- **Subscriptions**
  - Endpoint types
    - HTTP/HTTPS
    - Email
    - SQS
    - Lambda
    - SMS
    - Platform applications
  - Subscription filters
  - Delivery policies

### 2. Message Types
- **Standard**
  - Best-effort ordering
  - At-least-once delivery
  - No message ordering

- **FIFO**
  - Strict message ordering
  - Exactly-once processing
  - Message deduplication
  - Limited to SQS FIFO queues

### 3. Features
- Message filtering
- Message attributes
- Message archiving
- Dead-letter queues
- Large payload support
- Message encryption

## Amazon SQS (Simple Queue Service)

### 1. Queue Types
- **Standard Queues**
  - Unlimited throughput
  - At-least-once delivery
  - Best-effort ordering

- **FIFO Queues**
  - Strict ordering
  - Exactly-once processing
  - 300 messages/second
  - 3000 messages/second with batching

### 2. Message Properties
- **Visibility Timeout**
  - Processing time window
  - Message locking
  - Extendable timeout

- **Message Retention**
  - 1 minute to 14 days
  - Default 4 days
  - Configurable per queue

### 3. Features
- Dead-letter queues
- Delay queues
- Long polling
- Short polling
- Message attributes
- Message encryption

## Integration Patterns

### 1. Fanout Pattern
- Single SNS topic
- Multiple SQS queues
- Message distribution
- Parallel processing

### 2. Message Filtering
- Subscription filters
- Message attributes
- Content-based filtering
- Policy-based routing

### 3. Error Handling
- Dead-letter queues
- Retry policies
- Error notifications
- Message redrive

## Best Practices

### 1. Message Design
- Keep messages small
- Use message attributes
- Implement idempotency
- Handle duplicates

### 2. Performance
- Use batch operations
- Implement long polling
- Monitor queue depth
- Scale consumers

### 3. Security
- Use encryption
- Implement IAM policies
- Secure endpoints
- Monitor access

### 4. Cost Optimization
- Delete processed messages
- Use appropriate retention
- Monitor API usage
- Optimize polling

## Common Use Cases

### 1. Application Integration
- Microservices communication
- Event notification
- Email/SMS alerts
- Mobile push notifications

### 2. Distributed Systems
- Workload decoupling
- Load leveling
- Batch processing
- Fan-out architecture

### 3. Event-Driven Architecture
- Serverless applications
- Event processing
- Workflow automation
- Data processing

## Advanced Features

### 1. Message Filtering
- Attribute-based
- Content-based
- Policy-based
- Cross-account

### 2. Dead Letter Queues
- Error handling
- Message retention
- Troubleshooting
- Reprocessing

### 3. Security Features
- Server-side encryption
- Client-side encryption
- VPC endpoints
- IAM policies

## Exam Tips
- Understand differences between SNS and SQS
- Know queue types and their characteristics
- Understand message delivery guarantees
- Know about visibility timeout
- Understand dead-letter queues
- Know about message filtering
- Understand FIFO vs Standard
- Know about message attributes
- Understand fan-out pattern
- Know about long polling vs short polling
- Understand security features
- Know about message retention
- Understand scaling capabilities
- Know about cost optimization 