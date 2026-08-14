# Stage 1: Build the application
FROM clojure:lein-2.9.1-openjdk-8 AS builder

WORKDIR /app

# Install dependencies first (cache layer)
COPY common-utils/project.clj common-utils/
COPY front-end/project.clj front-end/
RUN cd front-end && lein install

# Copy source code
COPY front-end/src front-end/src
COPY front-end/resources front-end/resources

# Build the JAR
RUN cd front-end && lein uberjar

# Stage 2: Create minimal runtime image
FROM openjdk:8-jre-alpine

RUN apk add --no-cache bash wget

WORKDIR /app

# Copy the built JAR from builder stage
COPY --from=builder /app/front-end/target/uberjar/*-standalone.jar app.jar

EXPOSE 8000

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
  CMD wget --spider -q http://localhost:8000/ping || exit 1

CMD ["java", "-jar", "app.jar"]
