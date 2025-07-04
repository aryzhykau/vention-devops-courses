# GitHub Actions Setup

## Description
Instructions for setting up CI/CD pipeline using GitHub Actions with self-hosted runner for AWS deployment.

## Requirements
- Set up self-hosted runner on EC2 instance
- Create GitHub Actions workflow
- Configure AWS credentials
- Set up ECR repository
- Configure ECS deployment

## Self-Hosted Runner Setup

### 1. Create EC2 Instance for Runner
- Use Amazon Linux 2 or Ubuntu
- Minimum specs: t3.small (2 vCPU, 2 GB RAM)
- Attach IAM role with necessary permissions
- Security group: SSH access (port 22)

### 2. Install Dependencies
```bash
# Update system
sudo yum update -y  # Amazon Linux 2
# or
sudo apt update && sudo apt upgrade -y  # Ubuntu

# Install Docker
sudo yum install -y docker  # Amazon Linux 2
# or
sudo apt install -y docker.io  # Ubuntu

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### 3. Configure GitHub Runner
```bash
# Download runner
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz

# Configure runner
./config.sh --url https://github.com/aryzhykau/vention-devops-courses --token YOUR-TOKEN

# Install as service
sudo ./svc.sh install
sudo ./svc.sh start
```

## GitHub Actions Workflow Tasks

Create `.github/workflows/deploy.yml` with the following jobs:

### Job 1: Test (runs on ubuntu-latest)
- Checkout code
- Setup Node.js 18
- Install dependencies with npm ci
- Run tests
- Run linting

### Job 2: Build and Deploy (runs on self-hosted, depends on test)
- Checkout code
- Configure AWS credentials using secrets
- Login to Amazon ECR
- Build Docker image with multi-stage build
- Tag and push image to ECR
- Deploy infrastructure with Terraform
- Run health check

### Workflow Triggers
- Push to main branch
- Pull requests to main branch

### Environment Variables
- AWS_REGION: us-east-1
- ECR_REPOSITORY: aws-1st-service
- ECS_SERVICE: aws-1st-service-service
- ECS_CLUSTER: aws-1st-service-cluster
- ECS_TASK_DEFINITION: aws-1st-service-task

## Required GitHub Secrets

Configure these secrets in your GitHub repository:

- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key
- `DB_PASSWORD` - Database password
- `JWT_SECRET` - JWT signing secret

## IAM Permissions for Runner

The EC2 instance running the self-hosted runner needs these permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeServices",
        "ecs:DescribeTaskDefinition",
        "ecs:RegisterTaskDefinition",
        "ecs:UpdateService"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
```

## Important Notes

1. **Security**: Never commit AWS credentials to the repository
2. **Runner Security**: Keep the runner instance secure and updated
3. **Cost Optimization**: Stop the runner when not in use
4. **Monitoring**: Set up CloudWatch alarms for the runner instance
5. **Backup**: Regularly backup runner configuration

## Troubleshooting

### Common Issues:
- **Runner not connecting**: Check network connectivity and GitHub token
- **Docker permission denied**: Add user to docker group
- **AWS credentials error**: Verify IAM permissions and credentials
- **Terraform state locked**: Check for concurrent runs

### Useful Commands:
```bash
# Check runner status
sudo ./svc.sh status

# View runner logs
sudo journalctl -u actions.runner.*.service

# Restart runner
sudo ./svc.sh restart

# Check Docker
docker --version
docker ps
``` 