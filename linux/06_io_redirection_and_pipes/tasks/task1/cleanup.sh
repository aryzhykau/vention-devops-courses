#!/bin/bash

echo "Cleaning up I/O redirection practice environment..."

WORK_DIR="/tmp/io_practice"

# Remove all created files and directories
echo "Removing test files and directories..."
rm -rf "$WORK_DIR"

# Clean up any remaining file descriptors
echo "Cleaning up file descriptors..."
for fd in {3..9}; do
    exec {fd}>&- 2>/dev/null || true
done

echo "Cleanup completed successfully!" 