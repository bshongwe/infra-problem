# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for the DevOps Assessment solution.

## ADR Index

| ADR | Title | Status |
|-----|-------|--------|
| [ADR-001](ADR-001-docker-for-consistency.md) | Use Docker for local and cloud deployment | Accepted |
| [ADR-002](ADR-002-terraform-for-iac.md) | Use Terraform for Infrastructure as Code | Accepted |
| [ADR-003](ADR-003-digitalocean-as-cloud-provider.md) | Use DigitalOcean as primary cloud provider | Accepted |
| [ADR-004](ADR-004-multi-stage-docker-builds.md) | Use multi-stage Docker builds to compile Clojure | Accepted |
| [ADR-005](ADR-005-java-8-compatibility.md) | Use Java 8 base images for compatibility | Accepted |
| [ADR-006](ADR-006-branching-strategy.md) | Create devops-assessment branch for infrastructure | Accepted |

## What is an ADR?

An Architecture Decision Record (ADR) captures a significant architectural decision, the context surrounding it, and the consequences of that decision. This helps future maintainers understand why certain trade-offs were made.

## Template

Each ADR follows this structure:
- **Title**: Brief description of the decision
- **Status**: Proposed, Accepted, Deprecated, Superseded
- **Context**: Why we need to make this decision
- **Decision**: What we decided to do
- **Consequences**: The results of the decision (positive and negative)
