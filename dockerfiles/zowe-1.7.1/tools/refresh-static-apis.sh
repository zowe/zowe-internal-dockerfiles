#!/bin/sh
url=https://$HOSTNAME:7553/discovery/api/v1/staticApi
echo Refreshing static definitions $url
http --cert=/root/zowe/current/components/api-mediation/keystore/localhost/localhost.keystore.pem  POST $url
rc=$?
if [ $rc -ne 0 ]; then
    echo "Gateway on $HOSTNAME:7553 is not running" >&2
fi 
exit $rc