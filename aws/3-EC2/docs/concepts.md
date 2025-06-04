# AWS EC2 Concepts

## Overview
Amazon Elastic Compute Cloud (EC2) is a web service that provides secure, resizable compute capacity in the cloud. It is designed to make web-scale cloud computing easier for developers.

## Core Concepts

### 1. Instances
- Virtual servers in the cloud
- Can run various operating systems
- Multiple instance types available
- Pay-as-you-go pricing model

### 2. Instance Types
- **General Purpose (t3, m5)**
  - Balanced compute, memory, and networking
  - Suitable for web servers and development environments
  - Burstable performance with t3 instances

- **Compute Optimized (c5)**
  - High performance processors
  - Batch processing workloads
  - Scientific modeling
  - Gaming servers

- **Memory Optimized (r5)**
  - Fast performance for workloads processing large data sets
  - High performance databases
  - Distributed web scale cache stores
  - Real-time big data analytics

- **Storage Optimized (i3, d2)**
  - High, sequential read/write access to large data sets
  - NoSQL databases
  - Data warehousing
  - Log processing

- **Accelerated Computing (p3, g4)**
  - Hardware accelerators or co-processors
  - Machine learning
  - High performance computing
  - 3D visualizations

### 3. Amazon Machine Images (AMI)
- Pre-configured templates for instances
- Includes operating system and additional software
- Can be customized and saved
- Available from multiple sources:
  - AWS Marketplace
  - Community AMIs
  - Custom AMIs
  - Partner AMIs

### 4. Storage Options

#### EBS (Elastic Block Store)
- Persistent block storage volumes
- Types:
  - General Purpose SSD (gp2/gp3)
  - Provisioned IOPS SSD (io1/io2)
  - Throughput Optimized HDD (st1)
  - Cold HDD (sc1)
- Features:
  - Snapshots
  - Encryption
  - Elasticity
  - Independent lifecycle

#### Instance Store
- Temporary block-level storage
- Physically attached to host computer
- High I/O performance
- Data lost when instance stops

#### EFS (Elastic File System)
- Managed NFS file system
- Scalable and elastic
- Multi-AZ access
- Shared file storage

### 5. Networking

#### VPC Integration
- Launch instances in virtual private cloud
- Multiple network interfaces
- Public and private subnets
- Security groups and NACLs

#### Security Groups
- Virtual firewall for instances
- Control inbound and outbound traffic
- Stateful packet filtering
- Reference security groups from other security groups

#### Elastic IP
- Static public IPv4 address
- Can be associated/disassociated with instances
- Remains allocated until released
- Regional resource

### 6. Auto Scaling
- Automatically adjust capacity
- Maintain application availability
- Scale based on conditions:
  - Schedule
  - Demand
  - Predictive scaling
  - Target tracking

### 7. Load Balancing
- Distribute incoming traffic
- Types:
  - Application Load Balancer (Layer 7)
  - Network Load Balancer (Layer 4)
  - Gateway Load Balancer
  - Classic Load Balancer (Previous generation)

### 8. Instance Lifecycle
- Pending
- Running
- Stopping
- Stopped
- Shutting-down
- Terminated

### 9. Pricing Models
- **On-Demand**
  - Pay by the hour/second
  - No long-term commitments
  - Flexible and cost-effective

- **Reserved Instances**
  - 1 or 3 year commitment
  - Significant discount
  - Payment options:
    - All upfront
    - Partial upfront
    - No upfront

- **Spot Instances**
  - Bid for unused capacity
  - Variable pricing
  - Can be terminated with 2-minute notice
  - Significant cost savings

- **Dedicated Hosts**
  - Physical servers dedicated to your use
  - Full control over instance placement
  - Compliance and licensing requirements
  - Can be purchased On-Demand or Reserved

### 10. Monitoring and Management

#### CloudWatch Integration
- Basic monitoring (5-minute periods)
- Detailed monitoring (1-minute periods)
- Custom metrics
- Alarms and notifications

#### AWS Systems Manager
- Patch management
- Run commands
- Parameter Store
- Session Manager
- Automation

#### Tags
- Key-value pairs
- Resource organization
- Cost allocation
- Access control
- Automation

## Advanced Features

### 1. Placement Groups
- **Cluster**
  - Low-latency group in single AZ
  - High performance computing
- **Spread**
  - Instances on distinct hardware
  - Critical applications
- **Partition**
  - Groups of instances spread across partitions
  - Large distributed workloads

### 2. Instance Metadata
- Data about running instance
- Accessible via HTTP endpoint
- Instance identity
- User data

### 3. User Data
- Scripts run at launch
- Configure instances
- Install software
- Mount volumes

### 4. Enhanced Networking
- Higher bandwidth
- Lower latency
- Lower jitter
- Higher packets per second

### 5. Hibernate
- Save RAM contents to EBS
- Faster startup
- Preserve in-memory state
- Long-running processes

## Best Practices

### 1. Security
- Use security groups effectively
- Regular patching
- IAM roles instead of credentials
- Enable encryption
- Monitor and audit

### 2. Cost Optimization
- Right size instances
- Use appropriate pricing model
- Monitor and adjust capacity
- Implement auto scaling
- Tag resources for cost allocation

### 3. High Availability
- Use multiple AZs
- Implement auto scaling
- Use load balancers
- Regular backups
- Disaster recovery planning

### 4. Performance
- Choose appropriate instance types
- Use enhanced networking
- Monitor and optimize
- Use placement groups when needed
- Implement caching

### 5. Monitoring
- Enable detailed monitoring
- Set up alerts
- Monitor logs
- Track metrics
- Regular auditing 