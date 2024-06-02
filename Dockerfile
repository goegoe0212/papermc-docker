FROM eclipse-temurin:21-jre as base

WORKDIR /opt/minecraft

FROM base as build
ARG PAPERMC_VERSION BUILD JAR_NAME RCON_URL RCON_VERSION MAX_MEMORY MIN_MEMORY

ENV PAPERMC_DOWNLOAD_URL=https://api.papermc.io/v2/projects/paper/versions/${PAPERMC_VERSION}/builds/${BUILD}/downloads/paper-${PAPERMC_VERSION}-${BUILD}.jar

# Install Minecraft
RUN apt-get update -y && apt-get install -y wget

RUN wget -O paper.jar ${PAPERMC_DOWNLOAD_URL}

ENV RCON_DOWNLOAD_URL=https://github.com/gorcon/rcon-cli/releases/download/v${RCON_VERSION}/rcon-${RCON_VERSION}-amd64_linux.tar.gz

# RCONセットアップ
RUN wget -O rcon.tar.gz ${RCON_DOWNLOAD_URL} && \
    mkdir /usr/local/bin/rcon && \
    tar --strip-components=1 -xzf rcon.tar.gz -C /usr/local/bin/rcon

FROM base as final
ARG MAX_MEMORY MIN_MEMORY
# RCONのディレクトリをPATHに追加
ENV PATH="/usr/local/bin/rcon:${PATH}"
ENV XMX=-Xmx${MAX_MEMORY}M
ENV XMS=-Xms${MIN_MEMORY}M

COPY --from=build /opt/minecraft/paper.jar /opt/minecraft/paper.jar
COPY --from=build /usr/local/bin /usr/local/bin

RUN java -Xmx1G -Xms1G -jar paper.jar --nogui
RUN echo "eula=true" > eula.txt

ENTRYPOINT java $XMX $XMS -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:MaxGCPauseMillis=200 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar paper.jar nogui
