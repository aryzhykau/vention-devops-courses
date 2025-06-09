# AWS Container Services (ECS & EKS) Module

This module covers working with AWS container services, focusing primarily on Amazon ECS (Elastic Container Service) with an introduction to EKS (Elastic Kubernetes Service). All tasks are designed to work within AWS Free Tier limits.

## Module Structure

### EKS Overview (For Reference)

- Kubernetes architecture
- EKS cluster management
- Node groups
- Pod networking
- Kubernetes resources
- EKS security

## Prerequisites

- AWS Account with Free Tier access
- AWS CLI configured
- Docker installed and configured
- Basic understanding of containers
- Understanding of networking concepts
- Completed EC2 and VPC modules

## Free Tier Considerations

This module is designed to work within AWS Free Tier limits:
- Using t2.micro instances for ECS hosts
- Limiting number of instances to stay within Free Tier
- Using minimal EBS volumes
- Optimizing container resources
- Using Free Tier eligible load balancer hours

## Learning Objectives

After completing this module, you will be able to:

1. Design and implement containerized applications on ECS
2. Configure and manage ECS clusters
3. Deploy and scale container workloads
4. Implement container monitoring and logging
5. Optimize container deployments for cost and performance
6. Understand differences between ECS and EKS
7. Choose appropriate container orchestration solution

## Tools and Services

- AWS ECS CLI
- Docker CLI
- AWS CloudFormation/Terraform
- AWS CloudWatch
- AWS CodePipeline
- AWS Application Load Balancer

## Resources

- [Amazon ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [ECS Workshop](https://ecsworkshop.com/)
- [ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [Docker Documentation](https://docs.docker.com/)
- [AWS Container Blog](https://aws.amazon.com/blogs/containers/)


## Overview
Amazon Elastic Container Service (ECS) and Elastic Kubernetes Service (EKS) are fully managed container orchestration services. This module focuses on ECS with Free Tier compatible configurations.

## Amazon ECS (Elastic Container Service)

### 1. Core Components
- **Clusters**
  - Logical grouping of tasks
  - Regional scope
  - t2.micro instances
  - Free Tier optimization

- **Task Definitions**
  - Container definitions
  - Resource limits
  - Networking mode
  - Small volumes

- **Services**
  - Long-running tasks
  - Load balancing
  - Basic auto scaling
  - Rolling updates

### 2. Launch Types

- **EC2 Launch Type**
  - t2.micro instances
  - Cost optimization
  - Resource management
  - Capacity planning

### 3. Networking
- **VPC Mode**
  - Task networking
  - Security groups
  - Load balancer integration
  - Service discovery

## Best Practices

### 1. Architecture
- Use microservices
- Implement service discovery
- Plan for scaling
- Optimize for Free Tier

### 2. Operations
- Implement monitoring
- Use automated deployments
- Regular updates
- Resource optimization

### 3. Security
- Least privilege access
- Image scanning
- Network isolation
- Secrets management

### 4. Cost Optimization
- Use t2.micro instances
- Optimize container resources
- Monitor Free Tier usage
- Implement auto scaling

## Common Use Cases
1. Microservices
2. Web applications
3. API backends
4. Development environments
5. Testing environments
6. CI/CD pipelines

## Integration with AWS Services
- Application Load Balancer
- Route 53
- CloudWatch
- CloudTrail
- Systems Manager
- CodePipeline

## Exam Tips
- Understand ECS vs EKS differences
- Know launch types
- Understand networking modes
- Know about auto scaling
- Understand IAM roles
- Know about monitoring options
- Understand container security
- Know about service discovery
- Understand deployment strategies
- Know about load balancing
- Understand logging options
- Know about cost factors
- Understand high availability
- Know about disaster recovery 