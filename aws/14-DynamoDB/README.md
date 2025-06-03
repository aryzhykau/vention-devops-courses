# Amazon DynamoDB

## Overview
Amazon DynamoDB is a fully managed NoSQL database service that provides fast and predictable performance with seamless scalability. It offers consistent single-digit millisecond latency at any scale.

## Key Concepts

### 1. Data Model
- **Tables**
  - Collection of items
  - No schema required
  - Flexible data structure

- **Items**
  - Individual data records
  - No size limit
  - Maximum 400KB per item

- **Attributes**
  - Name-value pairs
  - Data types supported:
    - Scalar (String, Number, Binary, Boolean, Null)
    - Document (List, Map)
    - Set (String Set, Number Set, Binary Set)

## Capacity Modes

### 1. Provisioned Throughput
- **Read Capacity Units (RCU)**
  - Strongly consistent: 1 RCU = 1 read/second for items up to 4KB
  - Eventually consistent: 1 RCU = 2 reads/second for items up to 4KB

- **Write Capacity Units (WCU)**
  - 1 WCU = 1 write/second for items up to 1KB

### 2. On-Demand Mode
- Pay-per-request pricing
- Auto scaling
- No capacity planning
- More expensive per request

## Features and Capabilities

### 1. Consistency Models
- **Eventually Consistent Reads**
  - Lower cost
  - Higher availability
  - Default for GSI

- **Strongly Consistent Reads**
  - Most up-to-date data
  - Higher cost
  - Not available for GSI

### 2. DynamoDB Streams
- Time-ordered sequence
- Item-level changes
- 24-hour retention
- Lambda integration

### 3. Global Tables
- Multi-region replication
- Active-active configuration
- Eventually consistent
- Conflict resolution

## Advanced Features

### 1. DAX (DynamoDB Accelerator)
- In-memory cache
- Microsecond latency
- Write-through caching
- Query/Scan caching

### 2. Time To Live (TTL)
- Automatic item deletion
- Based on timestamp
- No additional cost
- Background process

### 3. Backup and Restore
- **On-demand backups**
  - Full backups
  - Zero impact
  - Manual retention

- **Point-in-time recovery**
  - Continuous backups
  - 35-day window
  - Per-second recovery

## Security

### 1. Authentication and Authorization
- IAM policies
- Fine-grained access
- Condition expressions
- Identity federation

### 2. Encryption
- **At rest**
  - AWS owned CMK
  - AWS managed CMK
  - Customer managed CMK

- **In transit**
  - TLS encryption
  - API endpoints
  - VPC endpoints

## Best Practices

### 1. Data Modeling
- Understand access patterns
- Minimize hot keys
- Use composite keys
- Plan for scaling

### 2. Performance
- Use appropriate key design
- Implement caching
- Batch operations
- Parallel scans

### 3. Cost Optimization
- Choose right capacity mode
- Use auto scaling
- Monitor usage
- Implement TTL

### 4. Application Design
- Handle throttling
- Use batch operations
- Implement retry logic
- Use consistent reads appropriately

## Common Use Cases
1. Mobile applications
2. Gaming leaderboards
3. Session management
4. Real-time analytics
5. Content management
6. Time-series data

## Integration with AWS Services
- Lambda
- API Gateway
- AppSync
- Amplify
- CloudWatch
- CloudTrail

## Exam Tips
- Understand partition key design
- Know consistency models
- Understand capacity units
- Know about secondary indexes
- Understand Global Tables
- Know about DAX
- Understand backup options
- Know about encryption
- Understand streams
- Know about TTL
- Understand IAM integration
- Know about scaling options
- Understand best practices
- Know about pricing models 