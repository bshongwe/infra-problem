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

# Documentation

- **[Solution Overview](docs/README.md)** - Complete overview of the DevOps solution
- **[Local Development Guide](docs/local-development.md)** - Set up your local environment
- **[Cloud Deployment Guide](docs/cloud-deployment.md)** - Deploy to the cloud
- **[Architecture Decision Records (ADRs)](docs/adr/README.md)** - Key technical decisions and rationale
- **[Security Considerations](SECURITY.md)** - Security notes and best practices

## Key Design Decisions

See the [ADRs](docs/adr/README.md) for detailed rationale behind major decisions:

- **ADR-001**: Why we use Docker for both local and cloud deployment
- **ADR-002**: Why we chose Terraform for Infrastructure as Code
- **ADR-003**: Why we selected DigitalOcean as the cloud provider
- **ADR-004**: Why Dockerfiles use multi-stage builds
- **ADR-005**: Why we use Java 8 base images
- **ADR-006**: Why we created the devops-assessment branch

These ADRs explain the trade-offs considered and help evaluators understand our decision-making process.

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


