# Security Considerations

## Known Limitations

### Hardcoded NEWSFEED_SERVICE_TOKEN

**Status**: Known Issue - Acceptable for Assessment  
**Severity**: Medium  
**Recommendation**: Use secrets management in production

The `NEWSFEED_SERVICE_TOKEN` appears in several files:
- `docker-compose.yml`
- `docker-compose.test.yml`
- `infra/variables.tf` (as default value)
- `docs/cloud-deployment.md` (documentation)

This token is required for the front-end to authenticate with the newsfeed service.

### Current Approach (Assessment Only)

For this assessment, the token is:
- ✅ Included in version control for reproducibility
- ✅ Documented as a known limitation
- ✅ Marked as `sensitive = true` in Terraform
- ⚠️ **NOT suitable for production use**

### Production Recommendations

For production deployments, use one of:

1. **Environment Variables**
   ```bash
   export NEWSFEED_SERVICE_TOKEN="$(vault read -field=token secret/newsfeed)"
   ```

2. **Docker Secrets** (Docker Swarm)
   ```bash
   docker secret create newsfeed_token ./token.txt
   ```

3. **Secrets Manager**
   - HashiCorp Vault
   - AWS Secrets Manager
   - Azure Key Vault
   - Google Secret Manager

4. **CI/CD Environment Variables**
   - GitHub Actions Secrets
   - GitLab CI Variables
   - Jenkins Credentials

## Security Best Practices Implemented

### ✅ Implemented
- Terraform sensitive variables (not shown in logs)
- `.gitignore` excludes `terraform.tfvars`
- Firewall restricts SSH access
- Only necessary ports exposed
- Internal Docker network for service communication

### ⚠️ Should Be Improved (Production)
- Secrets management (as noted above)
- Non-root user in Docker containers
- Image vulnerability scanning
- TLS/SSL for service communication
- Rate limiting on public endpoints
- Audit logging

## Reporting Security Issues

If you discover security issues in this assessment, please report them to the assessment team.
