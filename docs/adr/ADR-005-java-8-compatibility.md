# ADR-005: Use Java 8 Base Images for Compatibility

**Status**: Accepted  
**Date**: 2024-08-14  
**Deciders**: DevOps Assessment Team

## Context

The project's `develop` branch works but requires Java 8. The `master` branch is broken on modern Java versions (11+) due to:
- JAXB removal from JDK (javax.xml.bind.DatatypeConverter)
- http-kit library dependencies on removed Java modules
- Clojure 1.8.0 compatibility issues with newer JVMs

The current environment has Java 25 installed, which is incompatible with the project's dependencies.

## Decision

We will use **Java 8 JRE base images** in our Docker containers:

- **Base image**: `openjdk:8-jre-alpine`
- **Alpine Linux**: Minimal footprint (~100MB vs ~500MB for Ubuntu)
- **JRE (not JDK)**: Only need runtime, not compiler
- **Explicit version**: Pin to Java 8 to avoid surprises

## Consequences

### Positive
- **Guaranteed compatibility**: Application runs on correct Java version
- **No host Java required**: Developers can have any Java version installed
- **Consistent behavior**: Same Java version in all environments
- **Small image size**: Alpine-based, minimal attack surface
- **Security**: Java 8 still receives security updates (until 2030)

### Negative
- **Older Java version**: Missing features from newer Java releases
- **Potential security**: Java 8 has known CVEs (mitigated by Alpine updates)
- **Image maintenance**: Need to update base image periodically
- **Build complexity**: Multi-stage builds needed

## Alternatives Considered

### Alternative 1: Upgrade project to Java 11+
**Pros**: Modern Java, better performance, longer support  
**Cons**:
- Requires changing project.clj dependencies
- May break other dependencies
- Not our code to modify (client's codebase)
- Time-consuming
- Risk of introducing new bugs

**Rejected because**: We're deploying existing code, not modifying it

### Alternative 2: Use JVM arguments to enable JAXB
**Pros**: Keeps modern Java  
**Cons**:
- Requires adding Maven dependencies to project.clj
- Fragile - depends on library versions
- May not fix all compatibility issues
- Still modifying client's code

**Rejected because**: Modifying client's dependencies is risky

### Alternative 3: Require developers to install Java 8 locally
**Pros**: No Docker needed for runtime  
**Cons**:
- Poor developer experience
- Multiple Java versions conflict
- Different setup per OS
- Doesn't solve cloud deployment

**Rejected because**: Docker solves this more elegantly

## Java Version Details

**Selected**: OpenJDK 8u372-b08 (or later in 8 series)  
**Support timeline**: Public updates until March 2030 (LTS)  
**Security**: Alpine Linux patches backported

**Why not Java 11?**
- Project compiled with Clojure 1.8.0
- http-kit 2.1.18 may have issues on Java 11+
- JAXB still needs explicit dependencies
- Risk of breaking existing functionality

## Implementation Details

- Base image: `openjdk:8-jre-alpine`
- Alpine package manager: `apk`
- Additional packages: bash (for scripting)
- Health checks use `wget` (installed via Dockerfile if needed)

## Security Considerations

- Alpine Linux receives regular security patches
- Java 8 still maintained by OpenJDK
- Minimal attack surface (JRE only, not JDK)
- No SSH or package managers in final image
- Run as non-root user (future enhancement)

## Related Decisions
- ADR-001: Docker for consistency
- ADR-004: Multi-stage Docker builds
