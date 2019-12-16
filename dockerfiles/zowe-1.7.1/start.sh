#!/bin/bash
# Exposed ports cannot be changed (-p ...)
# Adjust hostname to match Docker host hostname and certificate in server.p12 (-h ...)
# Specify ZOSMF and ZSS hostnames and ports (--env ...)
# Provide location of your certificate (source=...)
# Certificate server.p12 must have password=password and keypair alias=apiml, keypair has to contain full certificate chain
# All certificates has to be stored in individual CER files.
# LAUNCH_COMPONENT_GROUPS valid values are GATEWAY and DESKTOP or GATEWAY,DESKTOP

#cp -r vlcvi01 /mnt/c/temp/vlcvi01

#    -p 60004:60004 \ #gatewayPort=7554    
#    -p 60002:7552 \ #catalogPort=7552
#    -p 60003:7553 \ #discoveryPort=7553  

docker run -it \
    -p 60004:60004 \
    -p 60014:8544 \
    -p 60002:7552 \
    -p 60003:7553 \
    -h 6W5PZY2.wifi.broadcom.net \
    --env ZOWE_ZOSMF_HOST=usilca32.lvn.broadcom.net \
    --env ZOWE_ZOSMF_PORT=1443 \
    --env ZOWE_ZSS_HOST=usilca32.lvn.broadcom.net \
    --env ZOWE_ZSS_PORT=60012 \
    --env LAUNCH_COMPONENT_GROUPS=GATEWAY \
    --mount type=bind,source=c:/temp/vlcvi01,target=/root/zowe/certs \
    --mount type=bind,source=c:/temp/vlcvi01-keystore,target=/root/zowe/1.7.1/components/api-mediation/keystore \
    --mount type=bind,source=c:/temp/vlcvi01-zowe-user-dir,target=/root/zowe-user-dir/api-mediation/api-defs \
    --mount type=bind,source=C:/Users/vv632728/workspaces/zowe,target=/root/zowe/src \
    zowe/docker:1.7.1 $@