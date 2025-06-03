#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "RDS Security Check Script"
echo "========================"

# Get instance identifier from Terraform output
INSTANCE_ID=$(terraform output -raw db_instance_identifier)

# Function to check security status
check_security_status() {
    local check_name=$1
    local check_command=$2
    local expected_value=$3
    
    echo -e "\n${YELLOW}Checking $check_name...${NC}"
    local result=$($check_command)
    
    if [ "$result" == "$expected_value" ]; then
        echo -e "${GREEN}✓ $check_name is properly configured${NC}"
        return 0
    else
        echo -e "${RED}✗ $check_name is not properly configured (Expected: $expected_value, Got: $result)${NC}"
        return 1
    fi
}

# Function to check encryption
check_encryption() {
    echo -e "\n${YELLOW}Checking Encryption Configuration...${NC}"
    
    # Check storage encryption
    ENCRYPTED=$(aws rds describe-db-instances \
        --db-instance-identifier $INSTANCE_ID \
        --query 'DBInstances[0].StorageEncrypted' \
        --output text)
    
    if [ "$ENCRYPTED" == "true" ]; then
        echo -e "${GREEN}✓ Storage encryption is enabled${NC}"
        
        # Check KMS key
        KMS_KEY=$(aws rds describe-db-instances \
            --db-instance-identifier $INSTANCE_ID \
            --query 'DBInstances[0].KmsKeyId' \
            --output text)
        
        if [ ! -z "$KMS_KEY" ]; then
            echo -e "${GREEN}✓ KMS key is configured: $KMS_KEY${NC}"
        else
            echo -e "${RED}✗ No KMS key configured${NC}"
        fi
    else
        echo -e "${RED}✗ Storage encryption is not enabled${NC}"
    fi
}

# Function to check network security
check_network_security() {
    echo -e "\n${YELLOW}Checking Network Security...${NC}"
    
    # Check public accessibility
    PUBLIC=$(aws rds describe-db-instances \
        --db-instance-identifier $INSTANCE_ID \
        --query 'DBInstances[0].PubliclyAccessible' \
        --output text)
    
    if [ "$PUBLIC" == "false" ]; then
        echo -e "${GREEN}✓ Instance is not publicly accessible${NC}"
    else
        echo -e "${RED}✗ Instance is publicly accessible${NC}"
    fi
    
    # Check security groups
    SG_COUNT=$(aws rds describe-db-instances \
        --db-instance-identifier $INSTANCE_ID \
        --query 'length(DBInstances[0].VpcSecurityGroups)' \
        --output text)
    
    if [ "$SG_COUNT" -gt "0" ]; then
        echo -e "${GREEN}✓ Security groups are configured${NC}"
        
        # List security group rules
        SG_IDS=$(aws rds describe-db-instances \
            --db-instance-identifier $INSTANCE_ID \
            --query 'DBInstances[0].VpcSecurityGroups[*].VpcSecurityGroupId' \
            --output text)
        
        for SG_ID in $SG_IDS; do
            echo -e "\nSecurity Group: $SG_ID"
            aws ec2 describe-security-group-rules \
                --filters Name=group-id,Values=$SG_ID \
                --query 'SecurityGroupRules[*].[IpProtocol,FromPort,ToPort,CidrIpv4]' \
                --output table
        done
    else
        echo -e "${RED}✗ No security groups configured${NC}"
    fi
}

# Function to check IAM authentication
check_iam_auth() {
    echo -e "\n${YELLOW}Checking IAM Authentication...${NC}"
    
    IAM_AUTH=$(aws rds describe-db-instances \
        --db-instance-identifier $INSTANCE_ID \
        --query 'DBInstances[0].IAMDatabaseAuthenticationEnabled' \
        --output text)
    
    if [ "$IAM_AUTH" == "true" ]; then
        echo -e "${GREEN}✓ IAM authentication is enabled${NC}"
    else
        echo -e "${RED}✗ IAM authentication is not enabled${NC}"
    fi
}

# Function to check monitoring
check_monitoring() {
    echo -e "\n${YELLOW}Checking Monitoring Configuration...${NC}"
    
    # Check Enhanced Monitoring
    MONITORING_INTERVAL=$(aws rds describe-db-instances \
        --db-instance-identifier $INSTANCE_ID \
        --query 'DBInstances[0].MonitoringInterval' \
        --output text)
    
    if [ "$MONITORING_INTERVAL" -gt "0" ]; then
        echo -e "${GREEN}✓ Enhanced Monitoring is enabled (${MONITORING_INTERVAL}s interval)${NC}"
    else
        echo -e "${RED}✗ Enhanced Monitoring is not enabled${NC}"
    fi
    
    # Check Performance Insights
    PERFORMANCE_INSIGHTS=$(aws rds describe-db-instances \
        --db-instance-identifier $INSTANCE_ID \
        --query 'DBInstances[0].PerformanceInsightsEnabled' \
        --output text)
    
    if [ "$PERFORMANCE_INSIGHTS" == "true" ]; then
        echo -e "${GREEN}✓ Performance Insights is enabled${NC}"
    else
        echo -e "${RED}✗ Performance Insights is not enabled${NC}"
    fi
    
    # Check CloudWatch Logs
    LOGS_EXPORTS=$(aws rds describe-db-instances \
        --db-instance-identifier $INSTANCE_ID \
        --query 'DBInstances[0].EnabledCloudwatchLogsExports' \
        --output text)
    
    if [ ! -z "$LOGS_EXPORTS" ]; then
        echo -e "${GREEN}✓ CloudWatch Logs are enabled: $LOGS_EXPORTS${NC}"
    else
        echo -e "${RED}✗ No CloudWatch Logs configured${NC}"
    fi
}

# Function to check backup configuration
check_backup() {
    echo -e "\n${YELLOW}Checking Backup Configuration...${NC}"
    
    # Check backup retention
    BACKUP_RETENTION=$(aws rds describe-db-instances \
        --db-instance-identifier $INSTANCE_ID \
        --query 'DBInstances[0].BackupRetentionPeriod' \
        --output text)
    
    if [ "$BACKUP_RETENTION" -gt "0" ]; then
        echo -e "${GREEN}✓ Automated backups are enabled (${BACKUP_RETENTION} days retention)${NC}"
    else
        echo -e "${RED}✗ Automated backups are not enabled${NC}"
    fi
    
    # Check backup window
    BACKUP_WINDOW=$(aws rds describe-db-instances \
        --db-instance-identifier $INSTANCE_ID \
        --query 'DBInstances[0].PreferredBackupWindow' \
        --output text)
    
    echo -e "${GREEN}✓ Backup window: $BACKUP_WINDOW${NC}"
}

# Main security check
echo -e "\n${YELLOW}Starting security checks...${NC}"

check_encryption
check_network_security
check_iam_auth
check_monitoring
check_backup

# Check AWS Config Rules
echo -e "\n${YELLOW}Checking AWS Config Rules...${NC}"

CONFIG_RULES=("rds-storage-encrypted" "rds-instance-public-access-check" "rds-multi-az-support")

for RULE in "${CONFIG_RULES[@]}"; do
    COMPLIANCE=$(aws configservice get-compliance-details-by-config-rule \
        --config-rule-name $RULE \
        --compliance-types COMPLIANT NON_COMPLIANT \
        --query 'EvaluationResults[0].ComplianceType' \
        --output text)
    
    if [ "$COMPLIANCE" == "COMPLIANT" ]; then
        echo -e "${GREEN}✓ $RULE: Compliant${NC}"
    else
        echo -e "${RED}✗ $RULE: Non-Compliant${NC}"
    fi
done

echo -e "\n${GREEN}Security check completed!${NC}" 