#!/bin/bash

if [ -n "$HOSTNAME" ]; then
  if [ -z "$ZOWE_EXPLORER_HOST" ]; then
    export ZOWE_EXPLORER_HOST=$HOSTNAME
  fi
fi

sed -i 's/ZOWE_USER_ID=ZWESVUSR/ZOWE_USER_ID=root/g' /root/zowe/install/bin/zowe-setup-certificates.env
sed -i 's/ZOWE_GROUP_ID=ZWEADMIN/ZOWE_GROUP_ID=root/g' /root/zowe/install/bin/zowe-setup-certificates.env

if [ -z "$VERIFY_CERTIFICATES" ]; then
  sed -i 's/VERIFY_CERTIFICATES=true/VERIFY_CERTIFICATES=false/g' /root/zowe/install/bin/zowe-setup-certificates.env
fi
sed -i 's/HOSTNAME=.*/HOSTNAME='"${ZOWE_EXPLORER_HOST}"'/g' /root/zowe/install/bin/zowe-setup-certificates.env
sed -i 's/IPADDRESS=.*/IPADDRESS='"${ZOWE_IP_ADDRESS}"'/g' /root/zowe/install/bin/zowe-setup-certificates.env

#sed -i 's/HOSTNAME=.*/HOSTNAME='"${ZOWE_EXPLORER_HOST}"'/g' /root/zowe/install/bin/zowe-setup-certificates.env
#sed -i 's/PKCS11_TOKEN_NAME=.*/PKCS11_TOKEN_NAME='"${PKCS11_TOKEN_NAME}"'/g' /root/zowe/install/bin/zowe-setup-certificates.env
#sed -i 's/PKCS11_TOKEN_LABEL=.*/PKCS11_TOKEN_LABEL='"${PKCS11_TOKEN_LABEL}"'/g' /root/zowe/install/bin/zowe-setup-certificates.env

#cat /root/zowe/install/bin/zowe-setup-certificates.env

/root/zowe/install/bin/zowe-setup-certificates.sh
sed -i 's/-ebcdic//' /global/zowe/keystore/zowe-certificates.env

cp /root/zowe/instance/instance.env.bkp /root/zowe/instance/instance.env

input="/root/zowe/instance/instance.env.bkp"
while read -r line
do
  test -z "${line%%#*}" && continue      # skip line if first char is #
  key=${line%%=*}
  if [ -n "${!key}" ]
  then
      echo "Replacing key=${key} with val=${!key}"
      sed -i 's/'${key}'=.*/'${key}'='"${!key}"'/g' /root/zowe/instance/instance.env
  fi
done < "$input"

bash /root/zowe/instance/bin/internal/run-zowe.sh
sleep infinity
