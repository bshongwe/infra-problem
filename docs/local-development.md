# Local Development Guide

This guide will help you set up the local development environment for the newsfeed microservices project.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Docker** (version 20.10 or higher) - https://docs.docker.com/get-docker/
- **Docker Compose** (version 2.0 or higher) - Usually included with Docker Desktop

### Verify Installation

```bash
docker --version
docker-compose --version
```

## Quick Start

The fastest way to get the application running is:

```bash
# Clone the repository (if you haven't already)
git clone https://github.com/melio-consulting/infra-problem.git
cd infra-problem

# Switch to the devops-assessment branch
git checkout devops-assessment

# Set up environment variables
cp .env.example .env
# Edit .env and set NEWSFEED_SERVICE_TOKEN to the real token value

# Start all services
docker-compose up
```

Once all services are running, visit **http://localhost:8000** in your web browser.

## Architecture Overview

The application consists of four Docker containers:

1. **quotes** (port 8080) - Serves random quotes
2. **newsfeed** (host port 8083 → container port 8081) - Aggregates RSS feeds
3. **front-end** (port 8000) - Main web application
4. **static-assets** (port 8001) - Serves CSS and static files

### Service Dependencies

```
front-end (8000)
    ├── quotes (8080)
    ├── newsfeed (8081 internal / 8083 on host)
    └── static-assets (8001)
```

## Common Tasks

### Start the Application

```bash
docker-compose up
```

To run in the background (detached mode):

```bash
docker-compose up -d
```

### Stop the Application

```bash
docker-compose down
```

To stop and remove volumes (clears any cached data):

```bash
docker-compose down -v
```

### View Logs

```bash
# View logs for all services
docker-compose logs -f

# View logs for a specific service
docker-compose logs -f quotes
docker-compose logs -f newsfeed
docker-compose logs -f front-end
```

### Rebuild Services

If you make changes to the source code, rebuild the services:

```bash
docker-compose build
docker-compose up
```

Or rebuild a specific service:

```bash
docker-compose build quotes
```

### Check Service Health

All services have health checks configured. To see the status:

```bash
docker-compose ps
```

You should see all services showing as "healthy".

### Access Service Endpoints

- **Front-end**: http://localhost:8000
- **Quotes API**: http://localhost:8080/api/quote
- **Newsfeed API**: http://localhost:8083/api/feeds
- **Health checks**:
  - http://localhost:8000/ping
  - http://localhost:8080/ping
  - http://localhost:8083/ping

## Environment Variables

The services are configured via environment variables defined in `docker-compose.yml`:

### Front-end Service

- `APP_PORT` - Port for the front-end service (default: 8000)
- `STATIC_URL` - URL for static assets (default: http://static-assets:8001)
- `QUOTE_SERVICE_URL` - URL for quotes service (default: http://quotes:8080)
- `NEWSFEED_SERVICE_URL` - URL for newsfeed service (default: http://newsfeed:8081)
- `NEWSFEED_SERVICE_TOKEN` - Authentication token for newsfeed service

### Quotes Service

- `APP_PORT` - Port for the quotes service (default: 8080)

### Newsfeed Service

- `APP_PORT` - Port for the newsfeed service (default: 8081)

### Custom Configuration

You can override environment variables by creating a `.env` file or modifying the `docker-compose.yml` file directly.

Example `.env` file:

```env
QUOTE_SERVICE_PORT=8080
NEWSFEED_SERVICE_PORT=8081
FRONTEND_PORT=8000
```

Then in docker-compose.yml, reference them:

```yaml
environment:
  - APP_PORT=${FRONTEND_PORT:-8000}
```

## Running Tests

### Run All Tests

```bash
docker-compose -f docker-compose.test.yml up --abort-on-container-exit
```

### Run Tests for Individual Services

```bash
# Quotes service tests
docker-compose -f docker-compose.test.yml run --rm quotes-test

# Newsfeed service tests
docker-compose -f docker-compose.test.yml run --rm newsfeed-test

# Front-end service tests
docker-compose -f docker-compose.test.yml run --rm front-end-test
```

## Debugging

### Access a Running Container

```bash
docker-compose exec quotes bash
docker-compose exec newsfeed bash
docker-compose exec front-end bash
```

### View Service Logs in Real-time

```bash
docker-compose logs -f --tail=100 front-end
```

### Check Network Connectivity

From inside a container:

```bash
docker-compose exec front-end wget -q -O- http://quotes:8080/ping
docker-compose exec front-end wget -q -O- http://newsfeed:8081/ping
```

## Troubleshooting

### Port Already in Use

If you see an error like "port is already allocated", you can change the ports in `docker-compose.yml`:

```yaml
ports:
  - "8001:8000"  # Maps host port 8001 to container port 8000
```

### Services Won't Start

1. Check Docker is running: `docker info`
2. Check logs: `docker-compose logs <service-name>`
3. Ensure no other processes are using the same ports
4. Try rebuilding: `docker-compose build --no-cache`

### Cannot Connect to Services

- Ensure all services are healthy: `docker-compose ps`
- Check that you're using the correct service URLs (internal Docker network URLs)
- Verify firewall settings aren't blocking ports

## Development Workflow

1. **Make code changes** in your local editor
2. **Rebuild the affected service**: `docker-compose build <service-name>`
3. **Restart the service**: `docker-compose up -d <service-name>`
4. **Verify the changes**: Visit http://localhost:8000
5. **Check logs if needed**: `docker-compose logs -f <service-name>`

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Main README](../README.md)
- [Cloud Deployment Guide](../docs/cloud-deployment.md)
