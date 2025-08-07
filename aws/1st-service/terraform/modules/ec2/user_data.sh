#!/bin/bash

# Update packages and install Docker
apt update -y
apt install -y docker.io unzip curl

# Enable Docker
systemctl enable docker
systemctl start docker

# Create a user for GitHub Runner
useradd -m github
usermod -aG docker github

# Switch to github user
cd /home/github
sudo -u github bash << EOF

# Download GitHub Actions runner
RUNNER_VERSION="2.317.0"
curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
mkdir actions-runner && tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -C actions-runner
cd actions-runner

# Install dependencies
./bin/installdependencies.sh

# Configure the runner (token placeholder)
./config.sh --url https://github.com/aryzhykau/vention-devops-courses --token PLACEHOLDER_TOKEN --unattended --labels ec2-runner

# Run the runner
./run.sh &

EOF
