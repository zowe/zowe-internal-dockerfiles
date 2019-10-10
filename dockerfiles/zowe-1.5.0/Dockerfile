FROM loyaltyone/docker-slim-java-node

EXPOSE 60004/tcp
EXPOSE 8544/tcp

ENV NODE_HOME='/usr/local'
ENV ZOWE_JAVA_HOME='/usr'

ENV ZOWE_ZOSMF_HOST='zosmf'
ENV ZOWE_ZOSMF_PORT='1443'
ENV ZOWE_ZSS_HOST='zss'
ENV ZOWE_ZSS_PORT='8542'

ENV LAUNCH_COMPONENT_GROUPS='GATEWAY,DESKTOP'

RUN apt-get update && apt-get install -y --no-install-recommends jq moreutils pax openjdk-8-jdk-headless build-essential mc wget && rm -rf /var/lib/apt/lists/*

RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

RUN mkdir /root/zowe/ && wget "https://d1xozlojgf8voe.cloudfront.net/builds/1.5.0/zowe-1.5.0.pax" -O /root/zowe/zowe-1.5.0.pax
COPY * /root/zowe/
RUN cd /root/zowe/; chmod o+r * && ./install.sh && rm -f /root/zowe/*.pax && rm -rf /root/zowe/zowe/ && apt-get purge -y pax build-essential && apt autoremove -y && rm -rf /var/lib/apt/lists/*

ENTRYPOINT (cd /root/zowe/ && ./run.sh && cd /root/zowe/1.5.0/scripts/internal && bash ./run-zowe.sh; sleep infinity)
