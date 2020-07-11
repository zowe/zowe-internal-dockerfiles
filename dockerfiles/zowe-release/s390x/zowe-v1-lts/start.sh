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
    -h localhost \
    --add-host=zowe.host.com:127.0.0.1 \
    --env ZOWE_ZOSMF_HOST=zosmf.host.com \
    --env ZOWE_ZOSMF_PORT=11443 \
    --env ZWED_agent_host=zss.host.com \
    --env ZWED_agent_http_port=11111 \
    --env LAUNCH_COMPONENT_GROUPS=DESKTOP,GATEWAY \
    zowe/docker:latest $@

    
