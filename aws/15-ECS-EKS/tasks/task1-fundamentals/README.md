# Task 1: ECS Fundamentals

This task focuses on the fundamental concepts and components of Amazon ECS (Elastic Container Service).

## Architecture Overview

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│             │     │             │     │             │
│    VPC      ├────►│    ECS     ├────►│    ECR      │
│             │     │  Cluster    │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
                          │
              ┌──────────┴──────────┐
              │                     │
        ┌─────┴─────┐         ┌─────┴─────┐
        │           │         │           │
        │   EC2    │         │   ALB     │
        │Instances │         │           │
        └───────────┘         └───────────┘
```

## Components

1. **ECS Cluster**
   - Cluster configuration
   - Capacity providers
   - Instance types
   - Auto Scaling groups
   - Container instances

2. **Task Definitions**
   - Container definitions
   - Resource allocation
   - Port mappings
   - Environment variables
   - Volume mounts

3. **ECS Service**
   - Service configuration
   - Deployment strategy
   - Load balancer integration
   - Service discovery
   - Health checks

4. **Networking**
   - VPC configuration
   - Security groups
   - Load balancer setup
   - Service discovery

## Prerequisites

- AWS CLI configured
- Docker installed
- Basic understanding of containers
- Completed VPC and EC2 modules

## Implementation Steps

1. **VPC Setup**
   ```hcl
   # VPC configuration
   resource "aws_vpc" "main" {
     cidr_block = var.vpc_cidr
     
     tags = {
       Name = "${var.project_name}-vpc"
     }
   }
   ```

2. **ECS Cluster Creation**
   ```hcl
   # ECS cluster
   resource "aws_ecs_cluster" "main" {
     name = "${var.project_name}-cluster"
     
     setting {
       name  = "containerInsights"
       value = "enabled"
     }
   }
   ```

3. **Task Definition**
   ```hcl
   # Task definition
   resource "aws_ecs_task_definition" "app" {
     family                   = "${var.project_name}-task"
     requires_compatibilities = ["EC2"]
     network_mode            = "awsvpc"
     cpu                     = var.task_cpu
     memory                  = var.task_memory
     
     container_definitions = jsonencode([
       {
         name  = var.container_name
         image = var.container_image
         portMappings = [
           {
             containerPort = var.container_port
             hostPort      = var.container_port
             protocol     = "tcp"
           }
         ]
       }
     ])
   }
   ```

4. **Service Configuration**
   ```hcl
   # ECS service
   resource "aws_ecs_service" "app" {
     name            = "${var.project_name}-service"
     cluster         = aws_ecs_cluster.main.id
     task_definition = aws_ecs_task_definition.app.arn
     desired_count   = var.service_desired_count
     
     network_configuration {
       subnets         = var.private_subnets
       security_groups = [aws_security_group.ecs_tasks.id]
     }
   }
   ```

## Files

- `main.tf` - Main infrastructure configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `iam.tf` - IAM roles and policies
- `app/`
  - `Dockerfile` - Container image definition
  - `src/` - Application source code
  - `docker-compose.yml` - Local development

## Validation Steps

1. **Cluster Verification**
   ```bash
   # Check cluster status
   aws ecs describe-clusters --clusters your-cluster-name
   ```

2. **Task Definition**
   ```bash
   # Verify task definition
   aws ecs describe-task-definition --task-definition your-task-family
   ```

3. **Service Status**
   ```bash
   # Check service status
   aws ecs describe-services --cluster your-cluster-name --services your-service-name
   ```

## Expected Outcomes

1. **Infrastructure**
   - Running ECS cluster
   - Registered container instances
   - Configured networking

2. **Application**
   - Running container tasks
   - Accessible endpoints
   - Proper logging

3. **Monitoring**
   - CloudWatch metrics
   - Container insights
   - Health checks

## Common Issues and Solutions

1. **Task Placement**
   - Insufficient resources
   - Incompatible instance types
   - Network configuration

2. **Container Issues**
   - Image pull failures
   - Port conflicts
   - Resource constraints

3. **Networking**
   - Security group rules
   - Load balancer health checks
   - Service discovery

## Monitoring and Logging

1. **CloudWatch Metrics**
   - CPU utilization
   - Memory usage
   - Network performance

2. **Container Insights**
   - Cluster metrics
   - Task metrics
   - Container metrics

3. **Application Logs**
   - Container logs
   - Service logs
   - Instance logs

## Security Considerations

1. **IAM Roles**
   - Task execution role
   - Task role
   - Instance role

2. **Network Security**
   - Security groups
   - NACLs
   - VPC endpoints

3. **Container Security**
   - Image scanning
   - Secrets management
   - Resource isolation

## Next Steps

After completing this task, you should:
1. Understand ECS core concepts
2. Be able to deploy basic containers
3. Know how to monitor ECS resources
4. Be ready for Task 2 (Service Deployment) 