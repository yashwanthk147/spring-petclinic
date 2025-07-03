#Build using Maven 3.8 and JDK 17
FROM maven:3.8.8-eclipse-temurin-17 AS builder

# Set working directory
WORKDIR /app

COPY pom.xml .

COPY . .

ENV MAVEN_OPTS="-Xmx1024m"

# Build the project
RUN mvn clean install -DskipTests

# Stage 2: Run with JDK 17
FROM eclipse-temurin:17-jre

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

# Expose port
EXPOSE 9090

# Run the application
CMD ["java", "-jar", "app.jar"]
