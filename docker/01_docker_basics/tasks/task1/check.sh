#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Counter for passed tests
PASSED=0
TOTAL=6

echo "Checking Docker installation and configuration..."

# Check 1: Docker installed
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker is installed"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Docker is not installed"
fi

# Check 2: Docker service running
if systemctl is-active --quiet docker; then
    echo -e "${GREEN}✓${NC} Docker service is running"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Docker service is not running"
fi

# Check 3: Docker Compose installed
if command -v docker-compose &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker Compose is installed"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Docker Compose is not installed"
fi

# Check 4: Current user in docker group
if groups | grep -q docker; then
    echo -e "${GREEN}✓${NC} Current user is in docker group"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Current user is not in docker group"
fi

# Check 5: Docker hello-world test
if docker run --rm hello-world | grep -q "Hello from Docker!"; then
    echo -e "${GREEN}✓${NC} Successfully ran hello-world container"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Failed to run hello-world container"
fi

# Check 6: Docker version check
if docker --version | grep -q "Docker version"; then
    echo -e "${GREEN}✓${NC} Docker version is available"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Cannot get Docker version"
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