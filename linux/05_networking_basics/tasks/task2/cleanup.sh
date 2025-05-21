#!/bin/bash

echo "Cleaning up web server practice environment..."

WORK_DIR="/tmp/webserver_practice"

# Stop the web server
if [ -f "$WORK_DIR/server.pid" ]; then
    echo "Stopping web server..."
    kill $(cat "$WORK_DIR/server.pid") 2>/dev/null
    rm "$WORK_DIR/server.pid"
fi

# Display logs before cleanup
if [ -f "$WORK_DIR/webserver.log" ]; then
    echo "Web server logs:"
    cat "$WORK_DIR/webserver.log"
fi

# Remove working directory
echo "Removing test files..."
rm -rf "$WORK_DIR"

echo "Cleanup completed successfully!" 