FROM openjdk:8-jre-alpine

RUN apk add --no-cache bash

WORKDIR /app

COPY target/uberjar/*-standalone.jar app.jar

EXPOSE 8000

CMD ["java", "-jar", "app.jar"]
