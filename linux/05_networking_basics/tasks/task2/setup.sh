#!/bin/bash

echo "Setting up web server practice environment..."

# Create working directory
WORK_DIR="/tmp/webserver_practice"
mkdir -p $WORK_DIR
cd $WORK_DIR

# Create test HTML file
cat > index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Test Page</title>
</head>
<body>
    <h1>Welcome to the Network Practice Server</h1>
    <p>This is a test page for the networking basics course.</p>
    <p>Current time: <span id="time"></span></p>
    <script>
        document.getElementById('time').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF

# Create Python web server script
cat > server.py << EOF
import http.server
import socketserver
import logging
import datetime

# Configure logging
logging.basicConfig(
    filename='webserver.log',
    level=logging.INFO,
    format='%(asctime)s - %(message)s'
)

class CustomHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        logging.info(f"{self.client_address[0]} - {format%args}")

PORT = 8080
Handler = CustomHandler

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Server started at port {PORT}")
    print("Access the server at http://localhost:8080")
    print("Press Ctrl+C to stop the server")
    httpd.serve_forever()
EOF

# Start the web server in the background
python3 server.py &
echo $! > server.pid

echo "Setup completed successfully!"
echo "Web server is running on port 8080"
echo "Test files are located in $WORK_DIR"
echo "You can now proceed with the tasks in the README.md file" 