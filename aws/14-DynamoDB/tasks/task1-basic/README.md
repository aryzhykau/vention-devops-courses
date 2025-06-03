# Task 1: Basic DynamoDB Operations

This task focuses on fundamental DynamoDB operations, including table creation, basic CRUD operations, and capacity management.

## Architecture Overview

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│              │     │              │     │              │
│  AWS SDK     ├────►│   DynamoDB   │◄────┤   Lambda     │
│              │     │              │     │              │
└──────────────┘     └──────────────┘     └──────────────┘
                           │
                    ┌──────┴───────┐
                    │              │
                    │ CloudWatch   │
                    │              │
                    └──────────────┘
```

## Components

1. **Table Design**
   - Primary key structure
   - Attribute definitions
   - Capacity settings
   - Table settings

2. **CRUD Operations**
   - Item creation
   - Item retrieval
   - Item updates
   - Item deletion
   - Batch operations

3. **Capacity Management**
   - Provisioned capacity
   - On-demand capacity
   - Auto-scaling configuration
   - CloudWatch monitoring

4. **Data Modeling**
   - JSON structure
   - Data types
   - Item collections
   - Basic queries

## Prerequisites

- Completed AWS Lambda module
- AWS CLI configured
- Basic understanding of NoSQL concepts
- Python programming experience

## Implementation Steps

1. **Table Creation**
   ```bash
   # Create DynamoDB table
   aws dynamodb create-table \
     --table-name Users \
     --attribute-definitions AttributeName=UserId,AttributeType=S \
     --key-schema AttributeName=UserId,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST
   ```

2. **Basic Operations**
   ```python
   # Python SDK example
   import boto3

   dynamodb = boto3.resource('dynamodb')
   table = dynamodb.Table('Users')

   # Create item
   table.put_item(
       Item={
           'UserId': '123',
           'Name': 'John Doe',
           'Email': 'john@example.com'
       }
   )
   ```

3. **Capacity Configuration**
   ```bash
   # Update to provisioned capacity
   aws dynamodb update-table \
     --table-name Users \
     --billing-mode PROVISIONED \
     --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
   ```

4. **Monitoring Setup**
   - Configure CloudWatch metrics
   - Set up capacity alerts
   - Monitor throttling events

## Files

- `main.tf` - Infrastructure configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `iam.tf` - IAM roles and policies
- `src/` - Application code
  - `crud_operations.py` - CRUD implementation
  - `capacity_manager.py` - Capacity management
  - `monitoring.py` - Monitoring setup
  - `requirements.txt` - Dependencies

## Validation Steps

1. **Table Creation**
   ```bash
   # Verify table exists
   aws dynamodb describe-table --table-name Users
   ```

2. **Data Operations**
   ```bash
   # Test item creation
   aws dynamodb put-item \
     --table-name Users \
     --item '{"UserId": {"S": "test"}, "Name": {"S": "Test User"}}'
   ```

3. **Capacity Testing**
   ```bash
   # Monitor consumed capacity
   aws dynamodb describe-table \
     --table-name Users \
     --query 'Table.ConsumedCapacity'
   ```

## Expected Outcomes

1. **Table Structure**
   - Properly configured table
   - Correct key schema
   - Appropriate capacity mode

2. **Operations**
   - Successful CRUD operations
   - Proper error handling
   - Efficient queries

3. **Capacity**
   - Optimal capacity settings
   - No throttling events
   - Cost-effective configuration

4. **Monitoring**
   - Active CloudWatch metrics
   - Configured alerts
   - Performance insights

## Common Issues and Solutions

1. **Throttling**
   - Increase capacity
   - Implement exponential backoff
   - Use batch operations

2. **Hot Partitions**
   - Review partition key design
   - Implement write sharding
   - Consider capacity distribution

3. **Cost Management**
   - Monitor usage patterns
   - Optimize capacity settings
   - Use auto-scaling effectively

## Monitoring and Logging

1. **CloudWatch Metrics**
   - ConsumedReadCapacityUnits
   - ConsumedWriteCapacityUnits
   - ThrottledRequests
   - SystemErrors

2. **Alerts**
   - Capacity threshold alerts
   - Error rate monitoring
   - Throttling notifications

3. **Logging**
   - Operation logs
   - Error tracking
   - Performance metrics

## Next Steps

After completing this task, you should:
1. Understand basic DynamoDB operations
2. Be able to manage table capacity
3. Know how to monitor performance
4. Be ready for Task 2 (Advanced Data Modeling) 