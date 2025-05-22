#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Counter for passed tests
PASSED=0
TOTAL=12

echo "Checking container management tasks..."

# Check 1: Named container exists
if docker ps -a | grep -q "my-container"; then
    echo -e "${GREEN}✓${NC} Named container exists"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Named container not found"
fi

# Check 2: Container with resource limits
if docker ps -a --format "{{.Names}} {{.Command}}" | grep -q "limited-container"; then
    echo -e "${GREEN}✓${NC} Resource-limited container exists"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Resource-limited container not found"
fi

# Check 3: Volume exists
if docker volume ls | grep -q "my-volume"; then
    echo -e "${GREEN}✓${NC} Docker volume exists"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Docker volume not found"
fi

# Check 4: Volume is mounted
if docker ps --format "{{.Mounts}}" | grep -q "my-volume"; then
    echo -e "${GREEN}✓${NC} Volume is mounted to a container"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Volume is not mounted"
fi

# Check 5: Custom network exists
if docker network ls | grep -q "my-network"; then
    echo -e "${GREEN}✓${NC} Custom network exists"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Custom network not found"
fi

# Check 6: Container connected to network
if docker network inspect my-network 2>/dev/null | grep -q "Containers"; then
    echo -e "${GREEN}✓${NC} Container is connected to network"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} No containers connected to network"
fi

# Check 7: Container with restart policy
if docker ps -a --format "{{.Names}} {{.Status}}" | grep -q "always"; then
    echo -e "${GREEN}✓${NC} Container has restart policy"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} No container with restart policy found"
fi

# Check 8: Container with bind mount
if docker ps --format "{{.Mounts}}" | grep -q "bind"; then
    echo -e "${GREEN}✓${NC} Container has bind mount"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} No bind mount found"
fi

# Check 9: Container logs available
if docker logs $(docker ps -q | head -n1) 2>/dev/null | grep -q "."; then
    echo -e "${GREEN}✓${NC} Container logs are available"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Container logs not available"
fi

# Check 10: Container stats available
if docker stats --no-stream $(docker ps -q | head -n1) 2>/dev/null | grep -q "CPU"; then
    echo -e "${GREEN}✓${NC} Container stats are available"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Container stats not available"
fi

# Check 11: Container inspect data
if docker inspect $(docker ps -q | head -n1) 2>/dev/null | grep -q "Config"; then
    echo -e "${GREEN}✓${NC} Container metadata is accessible"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Cannot access container metadata"
fi

# Check 12: DNS configuration
if docker inspect $(docker ps -q | head -n1) 2>/dev/null | grep -q "DNS"; then
    echo -e "${GREEN}✓${NC} DNS configuration is present"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} DNS configuration not found"
fi

# Print summary
echo -e "\nSummary: $PASSED out of $TOTAL checks passed"

# Exit with success only if all tests passed
if [ $PASSED -eq $TOTAL ]; then
    echo -e "\n${GREEN}All checks passed successfully!${NC}"
    exit 0
else
    echo -e "\n${RED}Some checks failed. Please review and fix the issues.${NC}"
    exit 1
fi 