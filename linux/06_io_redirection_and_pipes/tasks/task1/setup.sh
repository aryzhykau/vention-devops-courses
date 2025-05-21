#!/bin/bash

echo "Setting up I/O redirection practice environment..."

# Create working directory
WORK_DIR="/tmp/io_practice"
mkdir -p $WORK_DIR
cd $WORK_DIR

# Create sample text files
echo "Creating sample files..."

# Create a file with random words
cat > words.txt << EOF
zebra
apple
banana
orange
elephant
cat
dog
bird
fish
EOF

# Create a file that simulates a log with some errors
cat > mixed_output.txt << EOF
[INFO] System starting up
[ERROR] Failed to load configuration
[INFO] Using default settings
[WARNING] Disk space low
[ERROR] Could not connect to database
[INFO] Service started successfully
EOF

# Create a script that generates both output and errors
cat > test_script.sh << EOF
#!/bin/bash
echo "This is standard output"
echo "This is an error message" >&2
ls /nonexistent/directory
echo "This is more standard output"
EOF
chmod +x test_script.sh

# Create a numbered list for sorting practice
cat > numbers.txt << EOF
5
3
8
1
4
2
7
6
EOF

# Create a file for descriptor practice
echo "This is a test file for file descriptors" > descriptor_test.txt

echo "Setup completed successfully!"
echo "Test files have been created in $WORK_DIR:"
echo "- words.txt (for sorting practice)"
echo "- mixed_output.txt (contains both normal output and errors)"
echo "- test_script.sh (generates both stdout and stderr)"
echo "- numbers.txt (for sorting practice)"
echo "- descriptor_test.txt (for file descriptor practice)"
echo "You can now proceed with the tasks in the README.md file" 