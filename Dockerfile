# Stage-1: Build the application

FROM ubuntu:24.04 AS builder

RUN apt-get update
RUN apt-get install -y openjdk-21-jdk
RUN apt-get install -y maven

WORKDIR /app

COPY pom.xml .

RUN mvn dependency:go-offline -B

COPY src ./src

RUN mvn clean package -DskipTests


# Stage-2 copy and run the application

FROM ubuntu:24.04

RUN apt-get update && apt-get install -y openjdk-21-jdk wget tar && rm -rf /var/lib/apt/lists/*


ENV CATALINA_HOME=/opt/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

RUN mkdir -p $CATALINA_HOME

RUN wget https://archive.apache.org/dist/tomcat/tomcat-11/v11.0.27/bin/apache-tomcat-11.0.27.tar.gz && \
    tar -xzf apache-tomcat-11.0.27.tar.gz \
    --strip-components=1 \
    -C $CATALINA_HOME && \
    rm apache-tomcat-11.0.27.tar.gz

COPY --from=builder /app/target/petclinic.war $CATALINA_HOME/webapps/petclinic.war

EXPOSE 8080

CMD ["catalin.sh", "run"]


