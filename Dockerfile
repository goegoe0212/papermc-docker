FROM eclipse-temurin:21-jre as base

WORKDIR /opt/minecraft

FROM base as build
ARG PAPERMC_VERSION BUILD JAR_NAME

ENV DOWNLOAD_URL=https://api.papermc.io/v2/projects/paper/versions/$PAPERMC_VERSION/builds/$BUILD/downloads/paper-$PAPERMC_VERSION-$BUILD.jar

# Install Minecraft
RUN apt-get update -y && apt-get install -y wget

RUN wget -O paper.jar $DOWNLOAD_URL

FROM base as final

COPY --from=build /opt/minecraft/paper.jar /opt/minecraft/paper.jar

RUN java -Xmx1G -Xms1G -jar paper.jar --nogui
RUN echo "eula=true" > eula.txt


COPY ./entrypoint.sh /opt/minecraft/entrypoint.sh
# entrypoint.shを起動する。
ENTRYPOINT ["/bin/sh", "-c", "/opt/minecraft/entrypoint.sh"]

