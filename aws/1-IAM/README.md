# AWS Identity and Access Management (IAM)

## Overview
AWS Identity and Access Management (IAM) is a web service that helps you securely control access to AWS resources. With IAM, you can centrally manage permissions that control which AWS resources users can access.

## Key Concepts

### Users, Groups, and Roles
- **Users**: Entities representing people or applications
- **Groups**: Collection of users with shared permissions
- **Roles**: Set of permissions that can be assumed by users or services

### Policies
- **Identity-based policies**: Attached to users, groups, or roles
- **Resource-based policies**: Attached to resources
- **Permission boundaries**: Set maximum permissions
- **Service control policies (SCPs)**: Used in AWS Organizations

### Security Features
- Multi-factor authentication (MFA)
- Password policies
- Access keys rotation
- CloudTrail integration

## Best Practices
1. Follow the principle of least privilege
2. Use groups to assign permissions
3. Enable MFA for privileged users
4. Regularly rotate credentials
5. Use roles for applications and services
6. Monitor and audit access regularly

## Practical Tasks

### Task 1: Basic IAM Setup
Create a basic IAM configuration:
- Set up IAM users and groups
- Configure password policies
- Create and assign IAM roles
- Implement MFA
- Set up access keys rotation

[View Solution](./tasks/task1-basic-setup/)

### Task 2: Custom Policies
Create custom IAM policies:
- Design least privilege policies
- Create resource-based policies
- Implement permission boundaries
- Set up policy conditions
- Create inline vs managed policies

[View Solution](./tasks/task2-custom-policies/)

### Task 3: Cross-Account Access
Implement cross-account access:
- Set up cross-account roles
- Configure trust relationships
- Implement STS assume role
- Set up external ID
- Configure role session policies

[View Solution](./tasks/task3-cross-account/)

### Task 4: Federation Setup
Configure identity federation:
- Set up SAML integration
- Configure Web Identity federation
- Implement AWS SSO
- Set up role mapping
- Configure session policies

[View Solution](./tasks/task4-federation/)

### Task 5: Security and Monitoring
Implement IAM security controls:
- Set up CloudTrail monitoring
- Configure access analyzer
- Implement automated key rotation
- Set up compliance reporting
- Create security notifications

[View Solution](./tasks/task5-security/)

## Additional Resources
- [AWS IAM Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Security Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/security-best-practices.html) 