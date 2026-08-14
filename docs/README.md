# DevOps Assessment Solution

This branch contains the complete DevOps infrastructure solution for the newsfeed microservices project.

## What's Included

### 1. Local Development Environment (User Story 1)
- **Docker** configuration for all microservices
- **Docker Compose** setup for easy local deployment
- Consistent development environment across all machines

### 2. Cloud Deployment Environment (User Story 2)
- **Terraform** infrastructure as code for DigitalOcean
- Automated VM provisioning and deployment
- Reproducible cloud environment

## Quick Start

### Local Development

```bash
# Ensure you're on the devops-assessment branch
git checkout devops-assessment

# Start all services
docker-compose up

# Visit http://localhost:8000
```

See [Local Development Guide](docs/local-development.md) for detailed instructions.

### Cloud Deployment

```bash
cd infra

# Configure your DigitalOcean token
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your token

# Deploy
terraform init
terraform plan
terraform apply
```

See [Cloud Deployment Guide](docs/cloud-deployment.md) for detailed instructions.

## Architecture

The solution uses **Docker containers** for both local and cloud deployments, ensuring:

1. **Consistency**: Same runtime environment everywhere
2. **Portability**: Works on any machine with Docker installed
3. **Isolation**: Each service runs in its own container
4. **Scalability**: Easy to scale individual services

### Services

- **quotes** (port 8080) - Random quote API
- **newsfeed** (port 8081) - RSS feed aggregator
- **front-end** (port 8000) - Main web application
- **static-assets** (port 8001) - Static file server

### Technology Stack

- **Containerization**: Docker & Docker Compose
- **Infrastructure as Code**: Terraform
- **Cloud Provider**: DigitalOcean (IaaS)
- **Application**: Clojure microservices

## Documentation

- [Local Development Guide](docs/local-development.md) - Set up your local environment
- [Cloud Deployment Guide](docs/cloud-deployment.md) - Deploy to the cloud
- [Main README](README.md) - Original project documentation

## Key Decisions

### Why Docker?

- Solves Java version compatibility issues (Java 8 vs Java 25)
- Ensures consistency between local and cloud environments
- Simplifies dependency management
- Industry standard for containerization

### Why Terraform + DigitalOcean?

- True IaaS (not PaaS) - no vendor lock-in
- Simple, predictable pricing
- Easy to understand and modify
- Can be adapted to AWS, GCP, or Azure with minimal changes

### Why not build JARs locally?

The project requires Java 8, but modern systems have Java 11+. Rather than fighting version issues or requiring developers to install specific Java versions, Docker handles this automatically.

## Branch Structure

```
develop (baseline - working application code)
    │
    └── devops-assessment (this branch - infrastructure solution)
        ├── Dockerfiles
        ├── docker-compose.yml
        ├── Terraform configs
        └── Documentation
```

## Testing

### Run All Tests

```bash
docker-compose -f docker-compose.test.yml up --abort-on-container-exit
```

### Individual Service Tests

```bash
docker-compose -f docker-compose.test.yml run --rm quotes-test
docker-compose -f docker-compose.test.yml run --rm newsfeed-test
docker-compose -f docker-compose.test.yml run --rm front-end-test
```

## Clean Up

### Stop Local Services

```bash
docker-compose down
```

### Destroy Cloud Infrastructure

```bash
cd infra
terraform destroy
```

## Notes

- The `NEWSFEED_SERVICE_TOKEN` is currently hardcoded. In production, use a secrets manager.
- The cloud deployment uses the `devops-assessment` branch. Update `user-data.sh` if you use a different branch.
- Ports can be customized in `docker-compose.yml` and `terraform.tfvars`.
