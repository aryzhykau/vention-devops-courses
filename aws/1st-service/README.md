# AWS 1st Service - Intern Assignment

## 🎯 Assignment Goal

Create a complete AWS infrastructure using Terraform to deploy a web application with file upload capabilities and user registration.

## 📋 Requirements

### Infrastructure (Terraform)
Create modules in the `terraform/modules/` folder:

- **VPC** - private network with public and private subnets
- **Load Balancer** - Application Load Balancer for traffic distribution
- **EC2** - Auto Scaling Group with web servers
- **RDS** - PostgreSQL database in private subnet
- **S3** - bucket for file storage
- **IAM** - roles and policies for services

### Web Application
Develop an application in the `service/app/` folder:

- **Technology**: Next.js or Flask (your choice)
- **Functionality**:
  - Static homepage
  - User registration and authentication
  - File upload to S3
  - View uploaded files
  - Connect to PostgreSQL for user data storage

### Containerization
- Create Dockerfile for the application
- Configure multi-stage build for optimization

### CI/CD
- Set up GitHub Actions workflow
- Use self-hosted runner for deployment
- Automatic deployment on push to main branch

## 🏗️ Project Structure

```
aws/1st-service/
├── terraform/
│   ├── modules/
│   │   ├── vpc/           # VPC module
│   │   ├── loadbalancing/ # ALB module
│   │   ├── ec2/           # EC2 + Auto Scaling module
│   │   ├── rds/           # RDS PostgreSQL module
│   │   ├── s3/            # S3 module
│   │   └── iam/           # IAM roles module
│   └── infra/             # Main configuration
└── service/
    ├── app/               # Web application
    ├── docker/            # Docker configurations
    └── github-actions/    # CI/CD workflows
```

## 🚀 Implementation Steps

### 1. Infrastructure Preparation
1. Create Terraform modules for each component
2. Configure connections between modules
3. Ensure security (Security Groups, IAM)
4. Test infrastructure deployment

### 2. Application Development
1. Create basic web application
2. Implement registration/authentication functionality
3. Add file upload to S3
4. Configure PostgreSQL connection

### 3. Containerization
1. Create Dockerfile
2. Optimize image size
3. Add health check

### 4. CI/CD
1. Set up GitHub Actions workflow
2. Configure self-hosted runner
3. Automate deployment

## 🔧 Technical Requirements

### Security
- VPC with private subnets for RDS
- Security Groups with minimal permissions
- IAM roles with least privilege principle
- Data encryption in S3 and RDS

### Scalability
- Auto Scaling Group for EC2
- Read Replicas for RDS (optional)
- CloudFront for static content (optional)

### Monitoring
- CloudWatch metrics
- Logging to CloudWatch Logs
- Alerts for issues

## 📝 Evaluation Criteria

- [ ] Infrastructure deploys without errors
- [ ] Application is accessible through ALB
- [ ] Registration and authentication work
- [ ] Files upload to S3
- [ ] CI/CD pipeline works automatically
- [ ] Code follows best practices
- [ ] Documentation is written

## 💡 Hints

### Terraform
- Use data sources to get information about existing resources
- Apply count or for_each for creating multiple resources
- Don't forget outputs for passing data between modules

### Application
- Use environment variables for configuration
- Implement graceful shutdown
- Add logging

### Docker
- Use multi-stage builds
- Minimize number of layers
- Don't run container as root

### CI/CD
- Cache dependencies
- Use secrets for sensitive data
- Add testing stages

## 🆘 Useful Resources

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

**Good luck! And remember - a good DevOps engineer always thinks about security, scalability, and monitoring! 🚀** 