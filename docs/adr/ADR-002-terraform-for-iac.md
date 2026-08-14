# ADR-002: Use Terraform for Infrastructure as Code

**Status**: Accepted  
**Date**: 2024-08-14  
**Deciders**: DevOps Assessment Team

## Context

We need to provision cloud infrastructure that:
- Provides IaaS (not PaaS) per CIO requirements
- Is reproducible from a clean state
- Can be version controlled
- Is provider-agnostic (portable)
- Can be deployed with minimal manual intervention

The infrastructure needs to create a VM, install Docker, and deploy the microservices.

## Decision

We will use **Terraform** to provision cloud infrastructure as code:

1. **Provider**: DigitalOcean (primary), with notes for AWS/GCP/Azure
2. **Resources**: VM (Droplet), Firewall, SSH keys
3. **Provisioning**: Cloud-init script for automated setup
4. **Version control**: All Terraform code in `infra/` directory

## Consequences

### Positive
- **Infrastructure as Code**: Version controlled, peer reviewed
- **Reproducible**: Can recreate entire environment with one command
- **Provider agnostic**: Easy to switch cloud providers
- **Automated**: No manual server setup required
- **Documented**: Terraform code IS the documentation
- **Idempotent**: Can run multiple times safely

### Negative
- **Learning curve**: Team needs to learn Terraform syntax
- **State management**: Terraform state file needs to be managed
- **Provider lock-in**: Some provider-specific resources (mitigated by using standard IaaS)
- **Debugging**: Errors can be cryptic

## Alternatives Considered

### Alternative 1: Manual cloud setup with shell scripts
**Pros**: Simple, explicit control  
**Cons**:
- Not reproducible without documentation
- Error-prone manual steps
- Hard to track changes
- Not version controlled by default

**Rejected because**: Doesn't meet "reproducible from clean state" requirement

### Alternative 2: Cloud-specific tools (CloudFormation, ARM templates)
**Pros**: Native integration with cloud provider  
**Cons**:
- Vendor lock-in
- Different syntax per provider
- Steeper learning curve

**Rejected because**: CIO wants portability, not vendor-specific tools

### Alternative 3: Ansible/Puppet/Chef for provisioning
**Pros**: Powerful configuration management  
**Cons**:
- Additional tool to learn
- Overkill for single VM deployment
- Still need something to create the VM itself

**Rejected because**: Terraform handles both provisioning and deployment sufficiently

## Implementation Details

- Terraform v1.0+ required
- DigitalOcean provider plugin
- Cloud-init for VM initialization
- Variables for customization
- Outputs for accessing deployed resources

## Security Considerations

- Sensitive variables marked as `sensitive = true`
- API tokens not committed to version control
- `.gitignore` excludes `terraform.tfvars`
- Example file provided: `terraform.tfvars.example`

## Related Decisions
- ADR-003: DigitalOcean as cloud provider
- ADR-001: Docker for consistency
