#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Counter for passed tests
PASSED=0
TOTAL=7

echo "Checking nginx container setup and configuration..."

# Check 1: nginx image exists locally
if docker image ls | grep -q "nginx"; then
    echo -e "${GREEN}✓${NC} Nginx image is present locally"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Nginx image is not found locally"
fi

# Check 2: Container is running
if docker ps | grep -q "nginx"; then
    echo -e "${GREEN}✓${NC} Nginx container is running"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Nginx container is not running"
fi

# Check 3: Port mapping
if docker ps | grep -q "0.0.0.0:8080->80/tcp"; then
    echo -e "${GREEN}✓${NC} Port 8080 is correctly mapped"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Port 8080 is not mapped correctly"
fi

# Check 4: Web server accessibility
if curl -s http://localhost:8080 > /dev/null; then
    echo -e "${GREEN}✓${NC} Web server is accessible"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Web server is not accessible"
fi

# Check 5: Container logs are available
if docker logs $(docker ps -q --filter "ancestor=nginx") 2>&1 | grep -q "start"; then
    echo -e "${GREEN}✓${NC} Container logs are available"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Container logs are not available"
fi

# Check 6: Container can be stopped
CONTAINER_ID=$(docker ps -q --filter "ancestor=nginx")
if docker stop $CONTAINER_ID > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Container can be stopped"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Container cannot be stopped"
fi

# Check 7: Container can be started
if docker start $CONTAINER_ID > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Container can be started"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Container cannot be started"
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