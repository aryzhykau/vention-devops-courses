#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "RDS Task Validation Script"
echo "========================="

# Check AWS CLI configuration
echo -e "\n${YELLOW}Checking AWS CLI configuration...${NC}"
if aws sts get-caller-identity &>/dev/null; then
    echo -e "${GREEN}✓ AWS CLI is properly configured${NC}"
else
    echo -e "${RED}✗ AWS CLI is not properly configured${NC}"
    exit 1
fi

# Function to validate task1
validate_task1() {
    echo -e "\n${YELLOW}Validating Task 1 - Basic RDS Setup...${NC}"
    
    # Check if RDS instance exists
    INSTANCE_ID=$(terraform -chdir=task1-basic-setup output -raw db_instance_id 2>/dev/null)
    if [ $? -eq 0 ] && [ ! -z "$INSTANCE_ID" ]; then
        echo -e "${GREEN}✓ RDS instance exists: $INSTANCE_ID${NC}"
        
        # Check instance details
        aws rds describe-db-instances --db-instance-identifier $INSTANCE_ID --query 'DBInstances[0].[DBInstanceStatus,Engine,DBInstanceClass]' --output text
    else
        echo -e "${RED}✗ No RDS instance found${NC}"
    fi
}

# Function to validate task2
validate_task2() {
    echo -e "\n${YELLOW}Validating Task 2 - High Availability Setup...${NC}"
    
    # Check Multi-AZ configuration
    INSTANCE_ID=$(terraform -chdir=task2-high-availability output -raw db_instance_id 2>/dev/null)
    if [ $? -eq 0 ] && [ ! -z "$INSTANCE_ID" ]; then
        MULTI_AZ=$(aws rds describe-db-instances --db-instance-identifier $INSTANCE_ID --query 'DBInstances[0].MultiAZ' --output text)
        if [ "$MULTI_AZ" == "true" ]; then
            echo -e "${GREEN}✓ Multi-AZ is enabled${NC}"
        else
            echo -e "${RED}✗ Multi-AZ is not enabled${NC}"
        fi
        
        # Check read replicas
        READ_REPLICAS=$(aws rds describe-db-instances --db-instance-identifier $INSTANCE_ID --query 'DBInstances[0].ReadReplicaDBInstanceIdentifiers' --output text)
        if [ ! -z "$READ_REPLICAS" ]; then
            echo -e "${GREEN}✓ Read replicas configured: $READ_REPLICAS${NC}"
        else
            echo -e "${RED}✗ No read replicas found${NC}"
        fi
    else
        echo -e "${RED}✗ No RDS instance found${NC}"
    fi
}

# Function to validate task3
validate_task3() {
    echo -e "\n${YELLOW}Validating Task 3 - Security Implementation...${NC}"
    
    INSTANCE_ID=$(terraform -chdir=task3-security output -raw db_instance_id 2>/dev/null)
    if [ $? -eq 0 ] && [ ! -z "$INSTANCE_ID" ]; then
        # Check encryption
        ENCRYPTED=$(aws rds describe-db-instances --db-instance-identifier $INSTANCE_ID --query 'DBInstances[0].StorageEncrypted' --output text)
        if [ "$ENCRYPTED" == "true" ]; then
            echo -e "${GREEN}✓ Storage encryption is enabled${NC}"
        else
            echo -e "${RED}✗ Storage encryption is not enabled${NC}"
        fi
        
        # Check security group configuration
        SG_COUNT=$(aws rds describe-db-instances --db-instance-identifier $INSTANCE_ID --query 'length(DBInstances[0].VpcSecurityGroups)' --output text)
        if [ "$SG_COUNT" -gt "0" ]; then
            echo -e "${GREEN}✓ Security groups configured${NC}"
        else
            echo -e "${RED}✗ No security groups found${NC}"
        fi
    else
        echo -e "${RED}✗ No RDS instance found${NC}"
    fi
}

# Main validation logic
case "$1" in
    "task1")
        validate_task1
        ;;
    "task2")
        validate_task2
        ;;
    "task3")
        validate_task3
        ;;
    "all")
        validate_task1
        validate_task2
        validate_task3
        ;;
    *)
        echo "Usage: $0 {task1|task2|task3|all}"
        echo "Example: $0 task1"
        exit 1
        ;;
esac 