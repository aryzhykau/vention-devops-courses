#!/bin/bash

echo "Cleaning up pipes and filters practice environment..."

WORK_DIR="/tmp/pipes_practice"

# Remove working directory and all its contents
echo "Removing test files and directories..."
rm -rf "$WORK_DIR"

# Remove any temporary files that might have been created during practice
echo "Cleaning up temporary files..."
rm -f /tmp/pipeline_*.txt 2>/dev/null
rm -f /tmp/tee_*.txt 2>/dev/null

echo "Cleanup completed successfully!" 