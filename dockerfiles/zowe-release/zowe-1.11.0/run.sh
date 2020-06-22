#!/bin/bash

sed -i 's/-ebcdic//' /global/zowe/keystore/zowe-certificates.env
#sed -i -e 's/ZOWE_EXPLORER_FRAME_ANCESTORS="${ZOWE_EXPLORER_HOST}:*,${ZOWE_IP_ADDRESS}:*"/ZOWE_EXPLORER_FRAME_ANCESTORS="${ZOWE_EXPLORER_HOST}:*,${ZOWE_IP_ADDRESS}:*,${LINUX_HOST}:*"/g' /root/zowe/instance/instance.env
bash /root/zowe/instance/bin/internal/run-zowe.sh
sleep infinity

