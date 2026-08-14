# DevOps Assessment

This project contains three services:

* `quotes` which serves a random quote from `quotes/resources/quotes.json`
* `newsfeed` which aggregates several RSS feeds together
* `front-end` which calls the two previous services and displays the results.

## 🚀 Quick Start (Recommended)

### Option 1: Docker (Local Development)

```bash
# Use the devops-assessment branch for the complete solution
git checkout devops-assessment

# Start all services with Docker Compose
docker-compose up

# Visit http://localhost:8000
```

See [docs/local-development.md](docs/local-development.md) for detailed instructions.

### Option 2: Cloud Deployment

```bash
git checkout devops-assessment
cd infra
# Follow instructions in docs/cloud-deployment.md
```

See [docs/cloud-deployment.md](docs/cloud-deployment.md) for detailed instructions.

## Documentation

- **[Solution Overview](docs/README.md)** - Complete overview of the DevOps solution
- **[Local Development Guide](docs/local-development.md)** - Set up your local environment
- **[Cloud Deployment Guide](docs/cloud-deployment.md)** - Deploy to the cloud
- **[Original README](README-original.md)** - Original project documentation

## Original Documentation (For Reference)

The original documentation is preserved in `README-original.md`.

## Architecture

The system consists of three microservices:

1. **quotes** - Serves random quotes from a JSON file
2. **newsfeed** - Aggregates RSS feeds from various sources  
3. **front-end** - Calls the above services and displays results

### Service Communication

- Front-end calls:
  - Quotes service at `/api/quote`
  - Newsfeed service at `/api/feeds`

All services expose a `/ping` endpoint for health checks.

## Technology Stack

- **Language**: Clojure
- **Web Framework**: Compojure, Http-kit
- **Deployment**: Docker, Docker Compose
- **Infrastructure**: Terraform (for cloud deployment)
- **Cloud**: DigitalOcean IaaS (can be adapted to AWS, GCP, Azure)

## Testing

```bash
# Using Docker Compose
docker-compose -f docker-compose.test.yml up --abort-on-container-exit
```

## Branch Structure

- `develop` - Baseline branch with working application code
- `devops-assessment` - This solution branch with Docker and Terraform configurations
- `master` - Original branch (does not work)

## Prerequisites

For local development with Docker:
- Docker (version 20.10 or higher)
- Docker Compose (version 2.0 or higher)

For cloud deployment:
- Terraform (version 1.0 or higher)
- DigitalOcean account (or other cloud provider)

## License

This project is licensed under the MIT License.


