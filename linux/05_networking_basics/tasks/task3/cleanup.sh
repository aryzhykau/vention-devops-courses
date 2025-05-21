#!/bin/bash

echo "Cleaning up network traffic monitoring environment..."

WORK_DIR="/tmp/traffic_monitoring"

# Stop traffic generation
if [ -f "$WORK_DIR/traffic_gen.pid" ]; then
    echo "Stopping traffic generation..."
    kill $(cat "$WORK_DIR/traffic_gen.pid") 2>/dev/null
    pkill -f "python3 generate_traffic.py" 2>/dev/null
    rm "$WORK_DIR/traffic_gen.pid"
fi

# Remove working directory
echo "Removing test files..."
rm -rf "$WORK_DIR"

# Clean up any remaining tcpdump captures
echo "Cleaning up packet captures..."
rm -f /tmp/capture_*.pcap 2>/dev/null

echo "Cleanup completed successfully!" 