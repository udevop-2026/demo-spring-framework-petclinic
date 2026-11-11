Multi stage Dockerfile

# --------------------------------
# Stage 1: Build the Application
# --------------------------------
FROM ubuntu:24.04 AS builder

# Update packages
RUN apt-get update

# Install JDK 21 separately
RUN apt-get install -y openjdk-21-jdk

# Install Maven separately
RUN apt-get install -y maven

# Verify Java and Maven
RUN java -version
RUN mvn -version

# Set working directory
WORKDIR /app

# Copy pom.xml
COPY pom.xml .

# Download Maven dependencies
RUN mvn dependency:go-offline -B

# Copy application source code
COPY src ./src

# Build the WAR file
RUN mvn clean package -DskipTests


# --------------------------------
# Stage 2: Run Application on Tomcat
# --------------------------------
FROM tomcat:11-jdk21-temurin

# Remove default Tomcat applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR file from Stage 1
COPY --from=builder /app/target/petclinic.war \
    /usr/local/tomcat/webapps/petclinic.war

# Tomcat port
EXPOSE 6060

# Start Tomcat
CMD ["catalina.sh", "run"]
