#!/bin/bash

echo "Setting up pipes and filters practice environment..."

# Create working directory
WORK_DIR="/tmp/pipes_practice"
mkdir -p $WORK_DIR
cd $WORK_DIR

# Create a sample log file with various entries
cat > system.log << EOF
2024-01-01 10:15:32 [INFO] System startup
2024-01-01 10:15:33 [ERROR] Failed to load module X
2024-01-01 10:15:34 [INFO] Using fallback configuration
2024-01-01 10:15:35 [WARNING] Low memory condition
2024-01-01 10:15:36 [ERROR] Failed to load module X
2024-01-01 10:15:37 [INFO] Service A started
2024-01-01 10:15:38 [INFO] Service B started
2024-01-01 10:15:39 [ERROR] Failed to load module Y
2024-01-01 10:15:40 [INFO] System initialized
EOF

# Create a CSV file for field extraction practice
cat > users.csv << EOF
id,name,email,department
1,John Smith,john@example.com,IT
2,Jane Doe,jane@example.com,HR
3,Bob Wilson,bob@example.com,IT
4,Alice Brown,alice@example.com,Sales
5,Charlie Davis,charlie@example.com,HR
6,Eve Wilson,eve@example.com,Sales
EOF

# Create a file with duplicate lines for uniq practice
cat > data.txt << EOF
apple
apple
banana
orange
orange
orange
grape
apple
banana
kiwi
kiwi
EOF

# Create a command history simulation
cat > command_history.txt << EOF
ls -l /etc
grep error /var/log/syslog
cd /home/user
ps aux | grep nginx
top
ls -la
pwd
cd /tmp
ls -l
grep error /var/log/syslog
top
ls -l /etc
EOF

# Create a structured data file
cat > processes.txt << EOF
PID   CPU%  MEM%  COMMAND
1234  2.5   1.3   nginx
5678  1.8   0.7   sshd
9012  15.4  5.2   mysql
3456  0.5   0.3   cron
7890  8.9   3.1   apache2
2345  3.2   1.5   postgres
EOF

echo "Setup completed successfully!"
echo "Test files have been created in $WORK_DIR:"
echo "- system.log (for log analysis practice)"
echo "- users.csv (for field extraction practice)"
echo "- data.txt (for uniq/sort practice)"
echo "- command_history.txt (for command analysis)"
echo "- processes.txt (for data processing practice)"
echo "You can now proceed with the tasks in the README.md file" 