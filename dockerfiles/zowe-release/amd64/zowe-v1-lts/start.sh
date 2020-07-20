#!/bin/bash
# Exposed ports cannot be changed (-p ...)
# Adjust hostname to match Docker host hostname and certificate in server.p12 (-h ...)
# Specify ZOSMF and ZSS hostnames and ports (--env ...)
# Provide location of your certificate (source=...)
# Certificate server.p12 must have password=password and keypair alias=apiml, keypair has to contain full certificate chain
# All certificates has to be stored in individual CER files.
# LAUNCH_COMPONENT_GROUPS valid values are GATEWAY and DESKTOP or GATEWAY,DESKTOP



docker run -it \
    -p 7553:7553 \
    -p 7554:7554 \
    -p 8544:8544 \
    -h your_hostname \
    --env ZOWE_IP_ADDRESS=your.external.ip \
    --env LAUNCH_COMPONENT_GROUPS=DESKTOP,GATEWAY \
    --env ZOSMF_HOST=your.zosmainframe.com \
    --env ZWED_agent_host=your.zosmainframe.com \
    --env ZOSMF_PORT=11443 \
    --env ZWED_agent_http_port=8542 \
    rsqa/zowe-v1-lts:amd64 $@
