FROM maven:3-openjdk-17 AS build
WORKDIR /app
COPY .  .
RUN mvn package -DskipTests

FROM openjdk:19-slim-buster
WORKDIR /run
COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar /run/demo.jar

ARG USER=devops
ENV HOME /home/${USER}
RUN useradd -p password ${USER} && \
    chown ${USER}:${USER} /run/demo.jar

RUN apt update && apt install curl
HEALTHCHECK --interval=30s --timeout=10s --retries=2 --start-period=20s \
    CMD curl -f http://localhost:8080/ || exit 1

USER ${USER}

EXPOSE 8080
CMD java  -jar /run/demo.jar