#!/bin/bash

sed -i 's/-ebcdic//' /global/zowe/keystore/zowe-certificates.env
bash /root/zowe/instance/bin/internal/run-zowe.sh
sleep infinity

