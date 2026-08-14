# ADR-003: Use DigitalOcean as Primary Cloud Provider

**Status**: Accepted  
**Date**: 2024-08-14  
**Deciders**: DevOps Assessment Team

## Context

We need to choose a cloud provider for deploying the microservices. Requirements:
- IaaS (not PaaS) per CIO direction
- Simple VM provisioning
- Predictable pricing
- Good documentation
- Easy to use with Terraform

## Decision

We will use **DigitalOcean** as the primary cloud provider with Terraform support for AWS, GCP, and Azure documented.

### Specific Configuration
- **Service**: DigitalOcean Droplets (VMs)
- **Size**: s-2vcpu-4gb (2 vCPU, 4GB RAM, $24/month)
- **Image**: Ubuntu 22.04 LTS
- **Region**: Configurable (default: nyc3)

## Consequences

### Positive
- **Simple pricing**: Flat rate, easy to understand
- **Excellent Terraform support**: Official provider, well maintained
- **Fast VM provisioning**: Usually < 1 minute
- **Straightforward UI**: Easy to debug issues
- **Cost effective**: ~$24/month for suitable instance
- **Good documentation**: Extensive guides and tutorials

### Negative
- **Smaller market share**: Less community resources than AWS
- **Limited regions**: Fewer data centers than major providers
- **Fewer services**: No managed Kubernetes, advanced networking, etc.
- **Potential reliability concerns**: Not as battle-tested as AWS/GCP

## Alternatives Considered

### Alternative 1: AWS EC2
**Pros**: Largest provider, most features, very reliable  
**Cons**:
- Complex pricing model
- Steeper learning curve
- More configuration required (VPC, security groups, etc.)
- Overkill for simple VM deployment

**Rejected because**: DigitalOcean is simpler and sufficient for this use case

### Alternative 2: Google Cloud Platform
**Pros**: Good Terraform support, generous free tier  
**Cons**:
- More complex networking
- Less intuitive console
- Smaller market share than AWS

**Rejected because**: DigitalOcean has simpler pricing and UX

### Alternative 3: Azure
**Pros**: Enterprise-focused, good Windows support  
**Cons**:
- Complex portal
- Confusing naming conventions
- Higher learning curve

**Rejected because**: Not the best fit for simple Linux VMs

## Multi-Cloud Strategy

While DigitalOcean is the primary provider, the solution is designed to be portable:
- Terraform abstractions make provider switching straightforward
- Docker Compose deployment is cloud-agnostic
- Documentation includes examples for AWS, GCP, and Azure
- Core infrastructure (VM + Docker) is standard across all providers

## Cost Analysis

| Provider | Instance Type | Monthly Cost | Notes |
|----------|--------------|--------------|-------|
| DigitalOcean | s-2vcpu-4gb | ~$24 | Simple, flat rate |
| AWS | t3.small | ~$15 | + data transfer costs |
| GCP | e2-medium | ~$25 | Sustained use discounts |
| Azure | B2s | ~$20 | Pay-as-you-go pricing |

## Implementation Details

- DigitalOcean provider version ~> 2.0
- API token stored in `terraform.tfvars` (gitignored)
- Firewall resource for security
- Cloud-init for automated provisioning

## Related Decisions
- ADR-002: Terraform for IaC
- ADR-001: Docker for consistency
