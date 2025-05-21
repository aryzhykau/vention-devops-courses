#!/bin/bash

echo "Cleaning up advanced I/O practice environment..."

WORK_DIR="/tmp/advanced_io"

# Remove named pipes
echo "Removing named pipes..."
rm -f "$WORK_DIR/chat_pipe1" 2>/dev/null
rm -f "$WORK_DIR/chat_pipe2" 2>/dev/null

# Remove working directory and all its contents
echo "Removing test files and directories..."
rm -rf "$WORK_DIR"

# Clean up any remaining file descriptors
echo "Cleaning up file descriptors..."
for fd in {3..9}; do
    exec {fd}>&- 2>/dev/null || true
done

# Remove any temporary files that might have been created during practice
echo "Cleaning up temporary files..."
rm -f /tmp/process_subst_* 2>/dev/null
rm -f /tmp/here_doc_* 2>/dev/null

echo "Cleanup completed successfully!" 