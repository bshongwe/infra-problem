# ADR-004: Use Multi-Stage Docker Builds to Compile Clojure

**Status**: Accepted  
**Date**: 2024-08-14  
**Deciders**: DevOps Assessment Team

## Context

The Dockerfiles currently use `COPY target/uberjar/*-standalone.jar app.jar`, which requires pre-built JAR files to exist on the host machine before `docker-compose up`. This breaks the workflow:

1. Fresh developer clones repository
2. Runs `docker-compose up`
3. **Fails** - no JAR files exist yet
4. Developer must manually run `lein uberjar` first
5. But `lein` may not be installed or may be wrong Java version

This violates the acceptance criteria: "Given that I have set up the local environment... the front end application should be displayed."

## Decision

We will use **multi-stage Docker builds** to compile the Clojure code inside the containers:

### Stage 1: Builder
- Use full Clojure/Leiningen image
- Copy project files
- Run `lein uberjar` to compile
- Output: Standalone JAR file

### Stage 2: Runtime
- Use minimal Java 8 JRE image (Alpine)
- Copy JAR from builder stage
- Run the application

## Example Implementation

```dockerfile
# Stage 1: Build
FROM clojure:openjdk-8-lein AS builder
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app

# Build shared library dependency first
COPY common-utils/project.clj common-utils/
COPY common-utils/src common-utils/src
RUN cd common-utils && lein install

# Then build the service
COPY quotes/project.clj quotes/
RUN cd quotes && lein deps
COPY quotes/src quotes/src
COPY quotes/resources quotes/resources
RUN cd quotes && lein uberjar

# Stage 2: Runtime
FROM eclipse-temurin:8-jre-alpine
WORKDIR /app
COPY --from=builder /app/quotes/target/uberjar/*-standalone.jar app.jar
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
  CMD wget --spider -q http://localhost:8080/ping || exit 1
CMD ["java", "-jar", "app.jar"]
```

## Consequences

### Positive
- **Self-contained**: Docker image builds everything needed
- **No host dependencies**: Developers don't need Leiningen or Java installed
- **Fresh clone works**: `git clone && docker-compose up` just works
- **Consistent builds**: Same build environment everywhere
- **Smaller final images**: Build tools not included in runtime image
- **Faster iteration**: Docker caches build layers

### Negative
- **Longer initial build**: First build compiles everything (2-5 minutes)
- **Larger Docker context**: Need to copy all source files
- **Complexity**: Multi-stage builds are more complex than single stage
- **Build cache invalidation**: Code changes invalidate build cache

## Alternatives Considered

### Alternative 1: Keep current approach (pre-built JARs)
**Pros**: Faster container startup  
**Cons**:
- Requires manual build step
- Host must have correct Java/Leiningen version
- Poor developer experience
- Fails acceptance criteria

**Rejected because**: Breaks core user story

### Alternative 2: Build script that runs before docker-compose
**Pros**: Separates build from runtime  
**Cons**:
- Still requires Leiningen on host
- Additional step in documentation
- Doesn't solve Java version issue
- More complex workflow

**Rejected because**: Doesn't eliminate host dependencies

### Alternative 3: Use lein-ring plugin for development
**Pros**: Hot reloading, fast iteration  
**Cons**:
- Still requires Leiningen installed
- Different from production deployment
- Doesn't work for uberjar builds
- Inconsistent with cloud deployment

**Rejected because**: Requires Leiningen on host

## Implementation Details

- Build stage uses `clojure:openjdk-8-lein` image (current, actively maintained)
- Runtime stage uses `eclipse-temurin:8-jre-alpine` (minimal, maintained by Eclipse Foundation)
- **Critical**: Each service Dockerfile must build the `common-utils` shared library first before building the service itself
  - This ensures the common-utils JAR is available in the Maven local repository before service dependencies are resolved
  - Prevents "Could not find artifact com.thoughtworks:common-utils:jar:0.1.0-SNAPSHOT" errors
- Docker Compose will rebuild automatically when source changes
- Build cache speeds up subsequent builds
- All three services (quotes, newsfeed, front-end) use this pattern

## Common-Utils Dependency Build Order

This is a **critical implementation detail** that must be followed in each service's Dockerfile:

```dockerfile
# 1. Copy common-utils project metadata
COPY common-utils/project.clj common-utils/
COPY common-utils/src common-utils/src

# 2. Build and install common-utils to local Maven repository
RUN cd common-utils && lein install

# 3. THEN copy and build the service that depends on common-utils
COPY [SERVICE]/project.clj [SERVICE]/
RUN cd [SERVICE] && lein deps
COPY [SERVICE]/src [SERVICE]/src
RUN cd [SERVICE] && lein uberjar
```

Failure to follow this order results in dependency resolution failures during the Docker build.

## Build Time Optimization

To reduce build time:
- Docker layer caching reuses dependency downloads
- Mount source code as volume for development (optional)
- Pre-built base images in registry (for CI/CD)

## Related Decisions
- ADR-001: Docker for consistency
- ADR-005: Java 8 compatibility
- ADR-006: Branching strategy
