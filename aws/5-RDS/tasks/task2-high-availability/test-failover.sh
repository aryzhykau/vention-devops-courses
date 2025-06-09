#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "RDS High Availability Failover Test Script"
echo "========================================"

# Get instance identifier from Terraform output
INSTANCE_ID=$(terraform output -raw primary_instance_endpoint | cut -d'.' -f1)
REPLICA_ID=$(terraform output -raw read_replica_endpoint | cut -d'.' -f1)
CROSS_REGION_REPLICA_ID=$(terraform output -raw cross_region_replica_endpoint | cut -d'.' -f1)

# Function to check instance status
check_instance_status() {
    local instance_id=$1
    aws rds describe-db-instances \
        --db-instance-identifier $instance_id \
        --query 'DBInstances[0].DBInstanceStatus' \
        --output text
}

# Function to monitor failover
monitor_failover() {
    local instance_id=$1
    local start_time=$(date +%s)
    local timeout=600  # 10 minutes timeout

    echo -e "\n${YELLOW}Monitoring failover process...${NC}"
    
    while true; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [ $elapsed -gt $timeout ]; then
            echo -e "${RED}Failover monitoring timed out after 10 minutes${NC}"
            return 1
        fi

        local status=$(check_instance_status $instance_id)
        echo -e "Instance status: $status"
        
        if [ "$status" == "available" ]; then
            echo -e "${GREEN}Failover completed successfully${NC}"
            return 0
        fi
        
        sleep 30
    done
}

# Function to test connection
test_connection() {
    local endpoint=$1
    local max_attempts=5
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        echo -e "\n${YELLOW}Testing connection to $endpoint (Attempt $attempt)...${NC}"
        if mysql -h $endpoint -u $DB_USERNAME -p$DB_PASSWORD -e "SELECT 1;" &>/dev/null; then
            echo -e "${GREEN}Successfully connected to database${NC}"
            return 0
        else
            echo -e "${RED}Connection attempt $attempt failed${NC}"
            attempt=$((attempt + 1))
            sleep 10
        fi
    done
    
    echo -e "${RED}Failed to connect after $max_attempts attempts${NC}"
    return 1
}

# Main test scenarios
echo -e "\n${YELLOW}Starting failover tests...${NC}"

# 1. Test Multi-AZ Failover
echo -e "\n${YELLOW}Testing Multi-AZ Failover...${NC}"
echo "This will initiate a forced failover of the primary instance"
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Record current AZ
    ORIGINAL_AZ=$(aws rds describe-db-instances \
        --db-instance-identifier $INSTANCE_ID \
        --query 'DBInstances[0].AvailabilityZone' \
        --output text)
    
    echo "Current AZ: $ORIGINAL_AZ"
    
    # Initiate failover
    aws rds reboot-db-instance \
        --db-instance-identifier $INSTANCE_ID \
        --force-failover
    
    # Monitor failover
    if monitor_failover $INSTANCE_ID; then
        # Check new AZ
        NEW_AZ=$(aws rds describe-db-instances \
            --db-instance-identifier $INSTANCE_ID \
            --query 'DBInstances[0].AvailabilityZone' \
            --output text)
        
        if [ "$NEW_AZ" != "$ORIGINAL_AZ" ]; then
            echo -e "${GREEN}Failover successful! Instance moved from $ORIGINAL_AZ to $NEW_AZ${NC}"
        else
            echo -e "${RED}Failover may have failed. Instance is still in $NEW_AZ${NC}"
        fi
    fi
fi

# 2. Test Read Replica Promotion
echo -e "\n${YELLOW}Testing Read Replica Promotion...${NC}"
echo "This will promote the read replica to a standalone instance"
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Promote replica
    aws rds promote-read-replica \
        --db-instance-identifier $REPLICA_ID
    
    # Monitor promotion
    if monitor_failover $REPLICA_ID; then
        echo -e "${GREEN}Read replica promotion completed${NC}"
        
        # Test connection to promoted replica
        REPLICA_ENDPOINT=$(aws rds describe-db-instances \
            --db-instance-identifier $REPLICA_ID \
            --query 'DBInstances[0].Endpoint.Address' \
            --output text)
        
        test_connection $REPLICA_ENDPOINT
    fi
fi

# 3. Test Cross-Region Replica
echo -e "\n${YELLOW}Testing Cross-Region Replica...${NC}"
echo "This will verify the cross-region replica's status and replication lag"

# Check replication lag
REPLICA_LAG=$(aws rds describe-db-instances \
    --db-instance-identifier $CROSS_REGION_REPLICA_ID \
    --query 'DBInstances[0].ReplicaLag' \
    --output text)

echo "Current replication lag: ${REPLICA_LAG} seconds"

if [ $REPLICA_LAG -lt 300 ]; then
    echo -e "${GREEN}Replication lag is within acceptable range${NC}"
else
    echo -e "${RED}High replication lag detected${NC}"
fi

# Test connection to cross-region replica
CROSS_REGION_ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier $CROSS_REGION_REPLICA_ID \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text)

test_connection $CROSS_REGION_ENDPOINT

echo -e "\n${GREEN}Failover testing completed!${NC}" 