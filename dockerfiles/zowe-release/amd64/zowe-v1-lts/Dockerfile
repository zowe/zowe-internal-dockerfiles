FROM openjdk:11-jdk-slim

ARG PAX_FILE


RUN mkdir /root/zowe
COPY $PAX_FILE /root/zowe
RUN ls -ltr /root/zowe

COPY run.sh /root/zowe/

ENTRYPOINT ["/root/zowe/run.sh"]
