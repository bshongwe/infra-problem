# Stage 1: Build the application
FROM clojure:lein-2.9.1-openjdk-8 AS builder

WORKDIR /app

# Install dependencies first (cache layer)
COPY common-utils/project.clj common-utils/
COPY newsfeed/project.clj newsfeed/
RUN cd newsfeed && lein install

# Copy source code
COPY newsfeed/src newsfeed/src
COPY newsfeed/resources newsfeed/resources

# Build the JAR
RUN cd newsfeed && lein uberjar

# Stage 2: Create minimal runtime image
FROM openjdk:8-jre-alpine

RUN apk add --no-cache bash wget

WORKDIR /app

# Copy the built JAR from builder stage
COPY --from=builder /app/newsfeed/target/uberjar/*-standalone.jar app.jar

EXPOSE 8081

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
  CMD wget --spider -q http://localhost:8081/ping || exit 1

CMD ["java", "-jar", "app.jar"]
