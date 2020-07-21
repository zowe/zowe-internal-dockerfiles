#!/bin/bash
# Exposed ports cannot be changed (-p ...)
# Adjust hostname to match Docker host hostname and certificate in server.p12 (-h ...)
# Specify ZOSMF and ZSS hostnames and ports (--env ...)
# Provide location of your certificate (source=...)
# Certificate server.p12 must have password=password and keypair alias=apiml, keypair has to contain full certificate chain
# All certificates has to be stored in individual CER files.
# LAUNCH_COMPONENT_GROUPS valid values are GATEWAY and DESKTOP or GATEWAY,DESKTOP


DISCOVERY_PORT=7553
GATEWAY_PORT=7554
APP_SERVER_PORT=8544

docker run -it \
    -p ${DISCOVERY_PORT}:${DISCOVERY_PORT} \
    -p ${GATEWAY_PORT}:${GATEWAY_PORT} \
    -p ${APP_SERVER_PORT}:${APP_SERVER_PORT} \
    -h your_hostname \
    --env ZOWE_IP_ADDRESS=your.external.ip \
    --env LAUNCH_COMPONENT_GROUPS=DESKTOP,GATEWAY \
    --env ZOSMF_HOST=your.zosmainframe.com \
    --env ZWED_agent_host=your.zosmainframe.com \
    --env ZOSMF_PORT=11443 \
    --env ZWED_agent_http_port=8542 \
    --env GATEWAY_PORT=${GATEWAY_PORT} \
    --env DISCOVERY_PORT=${DISCOVERY_PORT} \
    --env ZOWE_ZLUX_SERVER_HTTPS_PORT=${APP_SERVER_PORT} \
    rsqa/zowe-v1-lts:s390x $@
