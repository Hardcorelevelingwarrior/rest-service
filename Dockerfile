
FROM openjdk:8-jre
ADD target/rest-service-1.0-SNAPSHOT.jar /usr/local/lib/demo.jar
RUN apt-get update -y
EXPOSE 8090
ENTRYPOINT ["java","-jar","/usr/local/lib/demo.jar",]
