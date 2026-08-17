# Architecture Decision Record

**Project**: Newsfeed Microservices — DevOps Assessment  
**Date**: 2025-05-04  
**Status**: Accepted

---

## 1. What I Chose and Why

**Docker + Docker Compose** for both local and cloud deployment. The application is written in Clojure and requires Java 8 and Leiningen to build. Rather than requiring developers to install specific toolchain versions, multi-stage Dockerfiles compile the code inside a `clojure:openjdk-8-lein` builder image and produce a minimal `eclipse-temurin:8-jre-alpine` runtime image. This means a clean `git clone` followed by `docker-compose up` is all that is needed — no host-level dependencies beyond Docker itself.

**Terraform** for Infrastructure as Code, targeting **DigitalOcean** as the cloud provider. Terraform provisions a single Ubuntu 22.04 Droplet, attaches a firewall, and runs a cloud-init script that installs Docker, clones the repository, and starts the services with `docker-compose up -d`. DigitalOcean was chosen over AWS or GCP for its simpler pricing, faster VM provisioning, and lower configuration overhead for a single-VM deployment — all appropriate given the time constraint.

**Architecture topology**: flat single-VM deployment. All four containers (quotes, newsfeed, front-end, static-assets) run on one Droplet connected via a Docker bridge network. The front-end is the only service exposed to the internet (port 8000); backend services communicate internally.

---

## 2. What I Considered and Ruled Out

- **PaaS (Heroku, ECS, App Engine)**: Ruled out immediately — the CIO explicitly requires IaaS for portability reasons.
- **AWS EC2 / GCP Compute Engine**: Valid alternatives. Ruled out in favour of DigitalOcean for simplicity and speed under the time constraint. The Terraform code is provider-agnostic enough that switching requires only changing the provider block and resource types.
- **Pre-built JARs copied into Docker images**: The original Dockerfiles used `COPY target/uberjar/*.jar`. This requires Leiningen on the host and breaks on a clean clone. Replaced with multi-stage builds.
- **Ansible for provisioning**: Overkill for a single VM. Terraform's `user_data` cloud-init script is sufficient and keeps the toolchain minimal.
- **Kubernetes**: Disproportionate complexity for three small services and a 4–5 hour window.

---

## 3. Tradeoffs Accepted

- **Single VM, no high availability**: All services share one host. A VM failure takes down the entire application. Acceptable for a shared test environment; not acceptable for production.
- **`docker-compose` on a raw VM instead of a container orchestrator**: Simpler to reason about and debug, but offers no automatic restarts beyond Docker's own restart policies, no rolling deploys, and no horizontal scaling.
- **No TLS**: The application is served over plain HTTP. Acceptable for an internal test environment; a production deployment would require a reverse proxy (nginx/Caddy) with TLS termination.
- **`NEWSFEED_SERVICE_TOKEN` sourced from a `.env` file**: The token is not committed to version control (`.env` is gitignored) but is also not managed by a secrets manager. Developers must set it manually from `.env.example`.

---

## 4. What I Would Address First With More Time

1. **Secrets management**: Replace the `.env` approach with a proper secrets manager (AWS Secrets Manager, HashiCorp Vault, or Docker Secrets) and remove the token from all documentation.
2. **TLS + reverse proxy**: Put nginx or Caddy in front of the front-end container to terminate HTTPS.
3. **High availability**: Move from a single VM to at least two VMs behind a load balancer, or migrate to a managed container platform (e.g. DigitalOcean App Platform, AWS ECS) once the IaaS portability concern is re-evaluated.
4. **CI/CD pipeline**: Automate image builds and pushes to a container registry on every commit, so the cloud VM pulls pre-built images rather than compiling from source on startup.
5. **Non-root container users**: The current Dockerfiles run as root inside the container. Production images should drop to a least-privilege user.
6. **Dependency vulnerability**: `common-utils` pulls in Clojure < 1.9.0 which has a known deserialization RCE (CVE / CWE-502). The dependency should be upgraded.
