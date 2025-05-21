#!/bin/bash

echo "Cleaning up network practice environment..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Remove virtual interface
echo "Removing virtual network interface dummy0..."
ip link set dummy0 down 2>/dev/null
ip link delete dummy0 2>/dev/null
rmmod dummy 2>/dev/null

# Check if backup exists and display original configuration
if [ -f /tmp/network_config_backup ]; then
    echo "Original network configuration was:"
    cat /tmp/network_config_backup
    rm /tmp/network_config_backup
fi

echo "Cleanup completed successfully!" 