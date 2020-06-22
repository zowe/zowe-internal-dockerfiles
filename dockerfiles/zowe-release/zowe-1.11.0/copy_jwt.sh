#!/bin/bash
sudo docker cp $1:/global/zowe/keystore/localhost/localhost.keystore.jwtsecret.p12 /tmp/jwtsecret.p12
ZSS_HOST=$(sudo docker exec $1 bash -c 'echo $ZOWE_ZSS_HOST')
P11_TOKEN_NAME=$(sudo docker exec $1 bash -c 'echo $PKCS11_TOKEN_NAME')
P11_TOKEN_LABEL=$($(sudo docker exec $1 bash -c 'echo $PKCS11_TOKEN_LABEL'))
echo "ZSS_HOST: ${ZSS_HOST} P11_NAME: ${P11_TOKEN_NAME} LABEL: ${P11_TOKEN_LABEL}"
sudo ssh $2@$ZSS_HOST "rm $3/jwtsecret.p12"
sudo scp /tmp/jwtsecret.p12 $2@$ZSS_HOST:$3/jwtsecret.p12