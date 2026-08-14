# Cloud Deployment Guide

This guide explains how to deploy the newsfeed microservices to a cloud provider using Infrastructure as Code (Terraform).

## Overview

We use **Terraform** to provision Infrastructure as a Service (IaaS) resources, specifically:
- A cloud virtual machine (DigitalOcean Droplet)
- Docker installed on the VM
- Docker Compose to orchestrate the microservices

This approach ensures:
- **No vendor lock-in**: Uses standard IaaS (not PaaS)
- **Portability**: Works across multiple cloud providers with minimal changes
- **Reproducibility**: Infrastructure can be recreated from code
- **Consistency**: Same deployment method as local development (Docker)

## Prerequisites

Before deploying to the cloud, ensure you have:

1. **Terraform** (version 1.0 or higher) - https://developer.hashicorp.com/terraform/downloads
2. **Cloud Provider Account** - We'll use DigitalOcean as the primary example
3. **Cloud Provider API Token** - For DigitalOcean: https://docs.digitalocean.com/reference/api/create-personal-access-token/

### Verify Installation

```bash
terraform version
```

## Quick Start - Deploy to DigitalOcean

### Step 1: Configure Cloud Provider Credentials

Create a `terraform.tfvars` file in the `infra/` directory:

```hcl
digitalocean_token = "your_digitalocean_api_token_here"
```

### Step 2: Initialize Terraform

```bash
cd infra
terraform init
```

### Step 3: Review the Deployment Plan

```bash
terraform plan
```

Review the resources that will be created:
- 1 DigitalOcean Droplet (VM)
- Associated networking resources

### Step 4: Deploy the Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### Step 5: Access the Application

After deployment completes, Terraform will output:
- The public IP address of the VM
- The URL to access the front-end application

```bash
# Example output:
# Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
#
# Outputs:
# front_end_url = "http://164.90.123.45:8000"
```

Visit the front-end URL in your browser.

## Infrastructure Components

### What Gets Created

1. **DigitalOcean Droplet** (or equivalent VM on other providers)
   - 2 vCPUs, 4GB RAM (suitable for the microservices)
   - Ubuntu 22.04 LTS
   - Docker and Docker Compose pre-installed

2. **Firewall/Security Group**
   - Port 22 (SSH) - Restricted to your IP
   - Port 8000 (HTTP) - Open to the internet
   - Port 8001 (Static Assets) - Open to the internet

3. **Deployment Scripts**
   - Automatically deploys the microservices via Docker Compose
   - Configures environment variables
   - Sets up health checks

### Architecture Diagram

```
Internet
    |
    | (Port 8000)
    v
Cloud VM (Droplet)
    |
    |-- Docker Compose
        |-- front-end (port 8000)
        |-- quotes (port 8080)
        |-- newsfeed (port 8081)
        |-- static-assets (port 8001)
```

## Terraform Configuration

### Directory Structure

```
infra/
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── terraform.tfvars.example # Example variables file
└── user-data.sh            # Cloud-init script for VM setup
```

### Key Variables

You can customize the deployment by modifying `terraform.tfvars`:

```hcl
# Cloud Provider
digitalocean_token = "your_token"

# VM Configuration
droplet_size   = "s-2vcpu-4gb"  # 2 vCPUs, 4GB RAM
droplet_region = "nyc3"         # New York 3
droplet_image  = "ubuntu-22-04-x64"

# Application Configuration
quotes_port    = 8080
newsfeed_port  = 8081
frontend_port  = 8000
```

## Deployment Process

### Automated Deployment

The deployment is fully automated:

1. Terraform provisions the VM
2. Cloud-init script runs on the VM:
   - Installs Docker and Docker Compose
   - Clones the repository from GitHub
   - Builds Docker images
   - Starts all services
3. Health checks verify all services are running

### Manual Deployment Steps

If you prefer to deploy manually:

1. **SSH into the VM**:
   ```bash
   ssh root@<vm-ip-address>
   ```

2. **Install Docker**:
   ```bash
   curl -fsSL https://get.docker.com | sh
   ```

3. **Install Docker Compose**:
   ```bash
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

4. **Clone and Deploy**:
   ```bash
   git clone https://github.com/melio-consulting/infra-problem.git
   cd infra-problem
   docker-compose up -d
   ```

## Accessing the Application

### Web Browser

Visit the front-end URL output by Terraform:
```
http://<vm-ip-address>:8000
```

### API Endpoints

```bash
# Health check
curl http://<vm-ip-address>:8000/ping

# Get a random quote
curl http://<vm-ip-address>:8080/api/quote

# Get newsfeed (requires auth token)
curl -H "X-Auth-Token: T1&eWbYXNWG1w1^YGKDPxAWJ@^et^&kX" \
  http://<vm-ip-address>:8081/api/feeds
```

## Updating the Deployment

### Update Application Code

1. Make changes to the code locally
2. Commit and push to GitHub
3. SSH into the VM and pull changes:
   ```bash
   ssh root@<vm-ip-address>
   cd /opt/newsfeed
   git pull origin devops-assessment
   docker-compose build
   docker-compose up -d
   ```

### Update Infrastructure

To modify the infrastructure (e.g., change VM size):

1. Update `terraform.tfvars` with new values
2. Run `terraform plan` to see changes
3. Run `terraform apply` to apply changes

## Destroying the Environment

When you're done testing, tear down the infrastructure to avoid ongoing costs:

```bash
cd infra
terraform destroy
```

Type `yes` when prompted.

**Warning**: This will permanently delete the VM and all data.

## Multi-Cloud Support

Terraform supports multiple cloud providers. To deploy to a different provider:

### AWS

Replace the DigitalOcean provider block with:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

And update the resource definitions to use AWS EC2 instances.

### Google Cloud Platform

```hcl
provider "google" {
  project = "your-project-id"
  region  = "us-central1"
}
```

### Azure

```hcl
provider "azurerm" {
  features {}
}
```

The core logic remains the same - provision a VM, install Docker, deploy the application.

## Security Considerations

### Secrets Management

The `NEWSFEED_SERVICE_TOKEN` is currently hardcoded in `docker-compose.yml`. For production deployments:

1. Use environment variables or a secrets manager
2. Never commit secrets to version control
3. Consider using Docker secrets or a vault solution

### Network Security

- SSH access is restricted to specific IPs (configurable in `variables.tf`)
- Only necessary ports are exposed
- Services communicate via internal Docker network

### Updates and Patching

- Regularly update the base Docker images
- Keep the host OS updated
- Monitor for security vulnerabilities in dependencies

## Monitoring and Logging

### View Application Logs

```bash
# Via Docker Compose
docker-compose logs -f

# Via SSH on the VM
docker logs <container-name>
```

### Health Monitoring

All services expose a `/ping` endpoint for health checks:

```bash
curl http://<vm-ip-address>:8000/ping
curl http://<vm-ip-address>:8080/ping
curl http://<vm-ip-address>:8081/ping
```

### Setting Up Monitoring

For production deployments, consider:
- Uptime monitoring (e.g., Pingdom, UptimeRobot)
- Application Performance Monitoring (e.g., New Relic, Datadog)
- Log aggregation (e.g., ELK Stack, Splunk)

## Cost Estimation

### DigitalOcean

- Droplet (2 vCPU, 4GB RAM): ~$24/month
- Bandwidth: First 1TB free, then $0.01/GB
- **Estimated total: $24-30/month**

### AWS EC2 (t3.small)

- EC2 instance: ~$15/month
- Data transfer: ~$5-10/month
- **Estimated total: $20-25/month**

## Troubleshooting

### Services Won't Start on VM

SSH into the VM and check Docker logs:

```bash
docker-compose logs
docker ps -a
```

### Cannot Access Application

1. Check firewall rules in cloud provider console
2. Verify Docker Compose is running: `docker-compose ps`
3. Check VM security group/network settings

### Terraform Errors

- Ensure your API token has the necessary permissions
- Check that you haven't exceeded resource limits
- Verify region availability

## Next Steps

- Set up CI/CD pipeline for automated deployments
- Add load balancer for high availability
- Implement automated backups
- Set up monitoring and alerting

