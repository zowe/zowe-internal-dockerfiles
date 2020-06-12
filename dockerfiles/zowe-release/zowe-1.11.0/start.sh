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
    -p 7554:7554 \
    -p 8544:8544 \
	-p 7553:7553 \
    -h localhost \
    --env ZOWE_ZOSMF_HOST=rs28.rocketsoftware.com \
    --env ZOWE_ZOSMF_PORT=11443 \
    --env ZOWE_ZSS_HOST=rs28.rocketsoftware.com \
    --env ZOWE_ZSS_PORT=15798 \
    --env LAUNCH_COMPONENT_GROUPS=DESKTOP,GATEWAY \
    zowe/docker:latest $@

    
