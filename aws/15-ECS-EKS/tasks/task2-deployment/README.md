# Task 2: ECS Service Deployment

This task focuses on advanced deployment strategies and service configuration in Amazon ECS.

## Learning Objectives

1. Implement different deployment strategies
2. Configure service discovery
3. Set up application load balancing
4. Implement auto scaling
5. Monitor service health
6. Manage container logs

## Components

### 1. Deployment Strategies
- Rolling update
- Blue/Green deployment
- Canary deployment
- A/B testing

### 2. Service Discovery
- AWS Cloud Map integration
- Service discovery naming
- DNS configuration
- Service mesh integration

### 3. Load Balancing
- Application Load Balancer setup
- Target group configuration
- Health check customization
- SSL/TLS termination

### 4. Auto Scaling
- Service Auto Scaling
- Target tracking policies
- Step scaling policies
- Scheduled scaling

### 5. Monitoring
- CloudWatch metrics
- Container insights
- Custom metrics
- Alarms and notifications

## Implementation Steps

1. **Configure Deployment Strategy**
   ```hcl
   resource "aws_ecs_service" "app" {
     # ... other configuration ...
     
     deployment_controller {
       type = "CODE_DEPLOY"
     }
     
     deployment_configuration {
       maximum_percent         = 200
       minimum_healthy_percent = 100
     }
   }
   ```

2. **Set Up Service Discovery**
   ```hcl
   resource "aws_service_discovery_private_dns_namespace" "app" {
     name        = "app.local"
     vpc         = aws_vpc.main.id
     description = "Service discovery namespace for app"
   }
   ```

3. **Configure Auto Scaling**
   ```hcl
   resource "aws_appautoscaling_target" "app" {
     max_capacity       = 10
     min_capacity       = 1
     resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
     scalable_dimension = "ecs:service:DesiredCount"
     service_namespace  = "ecs"
   }
   ```

## Project Structure

```
task2-deployment/
├── main.tf
├── variables.tf
├── outputs.tf
├── iam.tf
├── monitoring.tf
├── app/
│   ├── blue/
│   │   └── Dockerfile
│   └── green/
│       └── Dockerfile
└── templates/
    ├── task-definition.json
    └── appspec.yaml
```

## Prerequisites

- Completed Task 1 (ECS Fundamentals)
- AWS CodeDeploy service role
- Application Load Balancer
- Docker images in ECR

## Deployment Process

1. **Prepare Application**
   - Create Docker images
   - Push to ECR
   - Update task definition

2. **Configure CodeDeploy**
   - Create application
   - Create deployment group
   - Set up triggers and alarms

3. **Deploy Service**
   - Create service
   - Configure auto scaling
   - Set up monitoring

4. **Validate Deployment**
   - Check service status
   - Monitor deployment progress
   - Verify application health

## Monitoring and Logging

1. **CloudWatch Metrics**
   - CPU/Memory utilization
   - Request count
   - Error rates
   - Response times

2. **Container Insights**
   - Container metrics
   - Task metrics
   - Service metrics

3. **Application Logs**
   - Centralized logging
   - Log retention
   - Log analysis

## Security Considerations

1. **Network Security**
   - Security groups
   - NACLs
   - VPC endpoints

2. **Application Security**
   - SSL/TLS configuration
   - Secret management
   - IAM roles

3. **Monitoring Security**
   - Audit logging
   - CloudTrail integration
   - Security monitoring

## Best Practices

1. **Deployment**
   - Use immutable infrastructure
   - Implement rollback strategies
   - Test deployments in staging

2. **Scaling**
   - Set appropriate thresholds
   - Use target tracking when possible
   - Monitor scaling events

3. **Monitoring**
   - Set up comprehensive alarms
   - Use structured logging
   - Implement tracing

## Troubleshooting

1. **Common Issues**
   - Deployment failures
   - Scaling problems
   - Service discovery issues

2. **Resolution Steps**
   - Check CloudWatch logs
   - Review deployment events
   - Verify configuration

3. **Prevention**
   - Regular testing
   - Monitoring and alerts
   - Documentation

## Next Steps

After completing this task, you should:
1. Understand advanced deployment strategies
2. Be able to implement auto scaling
3. Know how to monitor services effectively
4. Be ready for Task 3 (ECS Fargate) 