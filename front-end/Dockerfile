# Stage 1: Build the application
FROM clojure:openjdk-8-lein AS builder

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Build shared dependency first so the service can resolve the local SNAPSHOT artifact
COPY common-utils/project.clj common-utils/
COPY common-utils/src common-utils/src
RUN cd common-utils && lein install

# Install service dependencies and build the app
COPY front-end/project.clj front-end/
RUN cd front-end && lein deps

COPY front-end/src front-end/src
COPY front-end/resources front-end/resources
RUN cd front-end && lein uberjar

# Stage 2: Create minimal runtime image
FROM eclipse-temurin:8-jre-alpine

RUN apk add --no-cache bash wget ca-certificates

WORKDIR /app

# Copy the built JAR from builder stage
COPY --from=builder /app/front-end/target/uberjar/*-standalone.jar app.jar

EXPOSE 8000

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
  CMD wget --spider -q http://localhost:8000/ping || exit 1

CMD ["java", "-Dcom.sun.jndi.ldap.connect.pool=false", "-jar", "app.jar"]
