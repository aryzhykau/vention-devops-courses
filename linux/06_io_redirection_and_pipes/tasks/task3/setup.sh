#!/bin/bash

echo "Setting up advanced I/O practice environment..."

# Create working directory
WORK_DIR="/tmp/advanced_io"
mkdir -p $WORK_DIR
cd $WORK_DIR

# Create named pipes
echo "Creating named pipes..."
mkfifo chat_pipe1
mkfifo chat_pipe2

# Create test files for process substitution
echo "Creating test files..."

# File 1 for comparison
cat > file1.txt << EOF
line 1
line 2
line 3
different line
line 5
EOF

# File 2 for comparison
cat > file2.txt << EOF
line 1
line 2
line 3
another different line
line 5
EOF

# Create a script template for here-document practice
cat > create_script.sh << EOF
#!/bin/bash
# This script demonstrates here-document usage
# You will modify this file using here-documents

echo "Original script content"
EOF
chmod +x create_script.sh

# Create a template configuration file
cat > config_template.txt << EOF
# Configuration file template
# Replace this with your own configuration using here-document

SERVER_NAME=localhost
PORT=8080
DEBUG=false
EOF

# Create a script demonstrating file descriptor usage
cat > fd_example.sh << EOF
#!/bin/bash
# This script demonstrates file descriptor usage
# You will modify this to practice advanced I/O

echo "Original file descriptor example"
EOF
chmod +x fd_example.sh

# Create a data processing script
cat > process_data.sh << EOF
#!/bin/bash
# This script will be used for process substitution practice
# You will modify this to process data streams

echo "Original data processing script"
EOF
chmod +x process_data.sh

echo "Setup completed successfully!"
echo "Test environment has been created in $WORK_DIR:"
echo "- Named pipes: chat_pipe1, chat_pipe2"
echo "- Comparison files: file1.txt, file2.txt"
echo "- Script templates: create_script.sh, fd_example.sh, process_data.sh"
echo "- Configuration template: config_template.txt"
echo "You can now proceed with the tasks in the README.md file"

# Display instructions for named pipe usage
echo -e "\nTo test named pipes, open two additional terminal windows and run:"
echo "Terminal 1: cat > chat_pipe1"
echo "Terminal 2: cat < chat_pipe1" 