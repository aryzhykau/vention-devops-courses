# Task 4: ECS Advanced Features

This task focuses on advanced features and integrations in Amazon ECS.

## Learning Objectives

1. Implement CI/CD pipelines
2. Configure blue/green deployments
3. Use capacity providers
4. Integrate service mesh
5. Customize container agents
6. Optimize spot instance usage

## Components

### 1. CI/CD Pipeline
- AWS CodePipeline
- AWS CodeBuild
- AWS CodeDeploy
- GitHub/CodeCommit integration
- Automated testing
- Deployment strategies

### 2. Service Mesh
- AWS App Mesh
- Service discovery
- Traffic routing
- Circuit breaking
- Observability

### 3. Capacity Management
- Capacity providers
- Spot Fleet integration
- Mixed instance policy
- Placement strategies
- Bin packing

### 4. Container Customization
- Custom AMIs
- Container agent configuration
- Task networking
- Resource management
- Logging drivers

## Implementation Steps

1. **CI/CD Pipeline**
   ```hcl
   resource "aws_codepipeline" "ecs" {
     name     = "${var.project_name}-pipeline"
     role_arn = aws_iam_role.codepipeline.arn
     
     artifact_store {
       location = aws_s3_bucket.artifacts.bucket
       type     = "S3"
     }
     
     stage {
       name = "Source"
       
       action {
         name            = "Source"
         category        = "Source"
         owner          = "AWS"
         provider        = "CodeCommit"
         version        = "1"
         output_artifacts = ["source"]
         
         configuration = {
           RepositoryName = aws_codecommit_repository.app.repository_name
           BranchName     = "main"
         }
       }
     }
     
     stage {
       name = "Build"
       
       action {
         name            = "Build"
         category        = "Build"
         owner          = "AWS"
         provider        = "CodeBuild"
         version        = "1"
         input_artifacts  = ["source"]
         output_artifacts = ["build"]
         
         configuration = {
           ProjectName = aws_codebuild_project.app.name
         }
       }
     }
     
     stage {
       name = "Deploy"
       
       action {
         name            = "Deploy"
         category        = "Deploy"
         owner          = "AWS"
         provider        = "CodeDeployToECS"
         version        = "1"
         input_artifacts = ["build"]
         
         configuration = {
           ApplicationName                = aws_codedeploy_app.app.name
           DeploymentGroupName           = aws_codedeploy_deployment_group.app.deployment_group_name
           TaskDefinitionTemplateArtifact = "build"
           AppSpecTemplateArtifact       = "build"
         }
       }
     }
   }
   ```

2. **App Mesh Configuration**
   ```hcl
   resource "aws_appmesh_mesh" "app" {
     name = "${var.project_name}-mesh"
     
     spec {
       egress_filter {
         type = "ALLOW_ALL"
       }
     }
   }
   
   resource "aws_appmesh_virtual_node" "app" {
     name      = "${var.project_name}-node"
     mesh_name = aws_appmesh_mesh.app.name
     
     spec {
       listener {
         port_mapping {
           port     = var.container_port
           protocol = "http"
         }
         
         health_check {
           protocol            = "http"
           path               = "/health"
           healthy_threshold   = 2
           unhealthy_threshold = 3
           timeout_millis     = 2000
           interval_millis    = 5000
         }
       }
       
       service_discovery {
         aws_cloud_map {
           namespace_name = aws_service_discovery_private_dns_namespace.app.name
           service_name   = var.service_name
         }
       }
     }
   }
   ```

## Project Structure

```
task4-advanced/
├── main.tf
├── variables.tf
├── outputs.tf
├── iam.tf
├── pipeline.tf
├── mesh.tf
├── capacity.tf
├── monitoring.tf
├── templates/
│   ├── buildspec.yml
│   ├── taskdef.json
│   └── appspec.yaml
└── app/
    ├── Dockerfile
    ├── src/
    └── tests/
```

## Advanced Features

### 1. Capacity Providers

```hcl
resource "aws_ecs_capacity_provider" "spot" {
  name = "${var.project_name}-spot"
  
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.spot.arn
    
    managed_scaling {
      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                   = "ENABLED"
      target_capacity          = 100
    }
  }
}
```

### 2. Custom Container Agent

```hcl
resource "aws_launch_template" "custom" {
  name_prefix   = "${var.project_name}-custom-"
  image_id      = var.custom_ami_id
  instance_type = var.instance_type
  
  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "ECS_CLUSTER=${aws_ecs_cluster.main.name}" >> /etc/ecs/ecs.config
              echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=1h" >> /etc/ecs/ecs.config
              echo "ECS_AVAILABLE_LOGGING_DRIVERS=[\"json-file\",\"awslogs\"]" >> /etc/ecs/ecs.config
              EOF
  )
}
```

## Integration Points

1. **Service Mesh Integration**
   - App Mesh configuration
   - Envoy proxy setup
   - Traffic routing rules
   - Observability setup

2. **CI/CD Pipeline**
   - Source code management
   - Build process
   - Testing strategy
   - Deployment automation

3. **Monitoring Integration**
   - CloudWatch metrics
   - X-Ray tracing
   - Container insights
   - Custom dashboards

## Advanced Configurations

### 1. Task Placement

```hcl
resource "aws_ecs_service" "advanced" {
  # ... other configuration ...
  
  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }
  
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.instance-type =~ t3.*"
  }
}
```

### 2. Service Discovery

```hcl
resource "aws_service_discovery_service" "app" {
  name = var.service_name
  
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.app.id
    
    dns_records {
      ttl  = 10
      type = "A"
    }
    
    routing_policy = "MULTIVALUE"
  }
  
  health_check_custom_config {
    failure_threshold = 1
  }
}
```

## Best Practices

1. **Pipeline Management**
   - Version control
   - Environment separation
   - Artifact management
   - Testing strategy

2. **Service Mesh**
   - Circuit breaking
   - Retry policies
   - Traffic splitting
   - Security policies

3. **Capacity Management**
   - Instance diversity
   - Spot instance handling
   - Scaling policies
   - Cost optimization

## Security Considerations

1. **Pipeline Security**
   - Artifact encryption
   - IAM roles
   - Secret management
   - Vulnerability scanning

2. **Network Security**
   - Service mesh policies
   - Network isolation
   - Traffic encryption
   - Access control

3. **Container Security**
   - Image scanning
   - Runtime protection
   - Resource isolation
   - Compliance monitoring

## Monitoring and Observability

1. **Metrics**
   - Service mesh metrics
   - Pipeline metrics
   - Custom metrics
   - Business metrics

2. **Logging**
   - Centralized logging
   - Log analytics
   - Audit logging
   - Error tracking

3. **Tracing**
   - Distributed tracing
   - Performance analysis
   - Dependency mapping
   - Bottleneck identification

## Next Steps

After completing this task, you should:
1. Understand advanced ECS features
2. Be able to implement CI/CD pipelines
3. Know how to use service mesh
4. Be proficient in capacity management 