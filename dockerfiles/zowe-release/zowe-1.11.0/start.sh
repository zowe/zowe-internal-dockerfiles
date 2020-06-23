#!/bin/bash
# Exposed ports cannot be changed (-p ...)
# Adjust hostname to match Docker host hostname and certificate in server.p12 (-h ...)
# Specify ZOSMF and ZSS hostnames and ports (--env ...)
# Provide location of your certificate (source=...)
# Certificate server.p12 must have password=password and keypair alias=apiml, keypair has to contain full certificate chain
# All certificates has to be stored in individual CER files.
# LAUNCH_COMPONENT_GROUPS valid values are GATEWAY and DESKTOP or GATEWAY,DESKTOP

#cp -r vlcvi01 /mnt/c/temp/vlcvi01
docker run -it \
    -p 9654:9654 \
    -p 9644:9644 \
    -p 9653:9653 \
    -h localhost \
	--add-host=zowe.host.com:127.0.0.1 \
    --env ZOWE_ZOSMF_HOST=zosmf.host.com \
    --env ZOWE_ZOSMF_PORT=11443 \
    --env ZOWE_ZSS_HOST=zss.host.com \
    --env ZOWE_ZSS_PORT=11111 \
    --env LAUNCH_COMPONENT_GROUPS=DESKTOP,GATEWAY \
    zowe/docker:latest $@

    
