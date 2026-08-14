#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Clone the repository
cd /opt
git clone ${github_repo} newsfeed
cd newsfeed
git checkout ${github_branch}

# Build and start services
docker-compose build
docker-compose up -d

# Wait for services to be healthy
echo "Waiting for services to start..."
sleep 30

# Check if services are running
docker-compose ps

echo "Deployment complete!"
echo "Front-end URL: http://$(curl -s ifconfig.me):${frontend_port}"
