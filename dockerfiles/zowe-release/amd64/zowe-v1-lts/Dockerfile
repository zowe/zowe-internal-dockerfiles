FROM openjdk:11-jdk-slim

RUN mkdir /root/zowe
COPY zowe.pax /root/zowe/
RUN ls -ltr /root/zowe

COPY run.sh /root/zowe/

ENTRYPOINT ["/root/zowe/run.sh"]
