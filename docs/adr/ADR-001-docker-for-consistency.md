# ADR-001: Use Docker for local and cloud deployment

**Status**: Accepted  
**Date**: 2024-08-14  
**Deciders**: DevOps Assessment Team

## Context

The project requires a consistent deployment method for both local development and cloud deployment. The application is written in Clojure and requires:
- Java 8 runtime
- Leiningen build tool
- Specific dependency versions
- Multiple microservices that need to communicate

Developers are on different operating systems (Windows, macOS, Linux) with varying Java versions installed. The CI/CD environment and cloud servers will have yet another configuration.

The master branch doesn't work due to Java compatibility issues. The develop branch works but requires specific setup.

## Decision

We will use **Docker containers** for both local development and cloud deployment:

1. **Local Development**: Docker Compose orchestrates all services
2. **Cloud Deployment**: Docker Compose runs on a cloud VM
3. **Consistent Runtime**: All environments use the same container images

## Consequences

### Positive
- **Environment consistency**: "It works on my machine" problem solved
- **Simplified onboarding**: New developers only need Docker installed
- **No Java version conflicts**: Container uses Java 8 regardless of host
- **Same deployment method**: Local and cloud use identical Docker Compose setup
- **Isolation**: Services run in isolated containers with their dependencies
- **Reproducibility**: Exact same environment everywhere

### Negative
- **Learning curve**: Developers need basic Docker knowledge
- **Resource overhead**: Docker Desktop consumes additional RAM/CPU
- **Build time**: Initial Docker image builds take time
- **Platform dependency**: Requires Docker to be installed

## Alternatives Considered

### Alternative 1: Native installation with Makefile
**Pros**: No Docker overhead, direct execution  
**Cons**: 
- Requires Java 8, Leiningen installed locally
- Different behavior across OSes
- Master branch broken on Java 11+
- More setup instructions needed

**Rejected because**: Inconsistent environments and Java compatibility issues

### Alternative 2: Use a PaaS (Heroku, ECS, App Engine)
**Pros**: Simpler deployment, managed infrastructure  
**Cons**:
- Violates CIO requirement for IaaS (no PaaS)
- Vendor lock-in
- Less control over infrastructure
- Higher long-term costs

**Rejected because**: CIO explicitly requires IaaS, not PaaS

### Alternative 3: Vagrant for local VMs
**Pros**: Consistent VM-based environment  
**Cons**:
- Heavier than Docker (full VM per developer)
- Slower startup times
- More resource intensive
- Still doesn't solve cloud deployment consistency

**Rejected because**: Docker is lighter and solves both local + cloud

## Implementation Details

- Base image: `openjdk:8-jre-alpine` (minimal Java 8)
- Multi-stage builds compile Clojure code inside containers
- Docker Compose for service orchestration
- Health checks ensure proper startup order
- Network bridge connects all services

## Related Decisions
- ADR-004: Multi-stage Docker builds
- ADR-005: Java 8 compatibility
- ADR-006: Branching strategy for solution
