#!/bin/bash

echo "Setting up network practice environment..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Create virtual interface
echo "Creating virtual network interface dummy0..."
modprobe dummy
ip link add dummy0 type dummy
ip addr add 192.168.100.10/24 dev dummy0
ip link set dummy0 up

# Save original network configuration
echo "Saving original network configuration..."
ip addr show > /tmp/network_config_backup

echo "Setup completed successfully!"
echo "Virtual interface dummy0 created with IP 192.168.100.10/24"
echo "You can now proceed with the tasks in the README.md file" 