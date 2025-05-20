#!/bin/bash

# This script cleans up the changes made by setup.sh for the Nginx troubleshooting assignment.
# It restores the original Nginx configuration and removes the problematic files.

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run the script as root (use sudo)."
  exit 1
fi

# Define variables (must match setup.sh)
TROUBLE_DIR="/opt/system_config_data"
INVALID_CONFIG="$TROUBLE_DIR/web_service_config"
NGINX_MAIN_CONFIG="/etc/nginx/nginx.conf"
NGINX_MAIN_CONFIG_BACKUP="$NGINX_MAIN_CONFIG.bak"

echo "Starting cleanup process..."

# 1. Restore original Nginx configuration from backup
echo "Restoring Nginx configuration from backup: $NGINX_MAIN_CONFIG_BACKUP"
if [ -f "$NGINX_MAIN_CONFIG_BACKUP" ]; then
    cp "$NGINX_MAIN_CONFIG_BACKUP" "$NGINX_MAIN_CONFIG"
    echo "Nginx configuration restored successfully."
else
    echo "Backup config file not found: $NGINX_MAIN_CONFIG_BACKUP"
    echo "Attempting to remove include line using sed as a fallback..."
    # Fallback: Try to remove the include line if backup is not found
    sed -i '/include \/opt\/system_config\_data\/web\_service\_config;/d' $NGINX_MAIN_CONFIG
    if [ $? -eq 0 ]; then
        echo "Include line removed using sed."
    else
        echo "Could not remove include line using sed. Manual intervention may be required."
    fi
fi

# 2. Remove the troubleshooting directory and files
echo "Removing troubleshooting directory: $TROUBLE_DIR"
if [ -d "$TROUBLE_DIR" ]; then
    rm -rf "$TROUBLE_DIR"
    echo "Troubleshooting directory removed successfully."
else
    echo "Troubleshooting directory not found. Nothing to remove."
fi


# 3. Remove Nginx package
echo "Removing Nginx package..."
apt remove --purge -y nginx
if [ $? -eq 0 ]; then
    echo "Nginx removed successfully."
else
    echo "Error removing Nginx package. Manual intervention may be required."
fi

# Note: Restarting Nginx is not needed after removal.

echo "Cleanup script finished." 