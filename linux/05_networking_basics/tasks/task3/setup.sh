#!/bin/bash

echo "Setting up network traffic monitoring environment..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Create working directory
WORK_DIR="/tmp/traffic_monitoring"
mkdir -p $WORK_DIR
cd $WORK_DIR

# Create traffic generation script
cat > generate_traffic.py << EOF
import http.server
import socketserver
import threading
import time
import socket
import requests
import random

def run_web_server():
    PORT = 8090
    Handler = http.server.SimpleHTTPRequestHandler
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"Web server running on port {PORT}")
        httpd.serve_forever()

def generate_http_traffic():
    while True:
        try:
            requests.get("http://localhost:8090")
            requests.post("http://localhost:8090", data={'test': 'data'})
            time.sleep(random.uniform(1, 3))
        except:
            pass

def generate_udp_traffic():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    while True:
        sock.sendto(b"Test UDP packet", ("127.0.0.1", 9999))
        time.sleep(random.uniform(0.5, 2))

# Start web server
threading.Thread(target=run_web_server, daemon=True).start()

# Start HTTP traffic generator
threading.Thread(target=generate_http_traffic, daemon=True).start()

# Start UDP traffic generator
threading.Thread(target=generate_udp_traffic, daemon=True).start()

# Keep script running
while True:
    time.sleep(1)
EOF

# Create test HTML file
echo "<html><body><h1>Test Page</h1></body></html>" > index.html

# Start traffic generation
python3 generate_traffic.py &
echo $! > traffic_gen.pid

echo "Setup completed successfully!"
echo "Traffic generation started. You can now use tcpdump or wireshark to analyze the traffic."
echo "Test environment is generating:"
echo "- HTTP traffic on port 8090"
echo "- UDP traffic on port 9999"
echo "You can now proceed with the tasks in the README.md file" 