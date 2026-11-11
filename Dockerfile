
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


# -------------------------------
# Stage 2: Install Tomcat manually
# -------------------------------
FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y openjdk-21-jdk wget tar && \
    rm -rf /var/lib/apt/lists/*

ENV CATALINA_HOME=/opt/tomcat                   
ENV PATH=$CATALINA_HOME/bin:$PATH               

RUN mkdir -p $CATALINA_HOME            

RUN wget https://archive.apache.org/dist/tomcat/tomcat-11/v11.0.27/bin/apache-tomcat-11.0.27.tar.gz && \
    tar -xzf apache-tomcat-11.0.27.tar.gz \
    --strip-components=1 \
    -C $CATALINA_HOME && \
    rm apache-tomcat-11.0.27.tar.gz


COPY --from=builder /app/target/petclinic.war \
    $CATALINA_HOME/webapps/petclinic.war

EXPOSE 8080

CMD ["catalina.sh", "run"]

