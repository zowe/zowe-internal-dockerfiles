#!/bin/bash
export PATH=$(pwd):$PATH
CERTS_DIR=/root/zowe/certs
ZOWE_INSTALL_ROOT=/root/zowe/1.6.0

DEBUG=""
set $DEBUG

export PATH=$PATH:$NODE_HOME/bin
export _BPXK_AUTOCVT=OFF
export ZOWE_IPADDRESS=127.0.0.1
export ZOWE_EXPLORER_HOST=$HOSTNAME
export ZOWE_ZOSMF_HOST=$ZOWE_ZOSMF_HOST
export ZOWE_ZOSMF_PORT=$ZOWE_ZOSMF_PORT

env
echo "Installation root $ZOWE_INSTALL_ROOT" 
if [ "$1" = "--only-install" ]; then
    echo "Only the installation is finished, type exit to proceed to configuration"
    cd $ZOWE_INSTALL_ROOT
    bash
fi
sed -i 's/gatewayPort=7554/gatewayPort=60004/' $ZOWE_INSTALL_ROOT/scripts/configure/zowe-install.yaml
sed -i "s/externalCertificate=/externalCertificate=$(echo "$CERTS_DIR/server.p12" |  sed 's/\//\\\//g')/" $ZOWE_INSTALL_ROOT/scripts/configure/zowe-install.yaml
sed -i 's/externalCertificateAlias=/externalCertificateAlias=apiml/' $ZOWE_INSTALL_ROOT/scripts/configure/zowe-install.yaml
sed -i "s/externalCertificateAuthorities=/externalCertificateAuthorities=$(find $CERTS_DIR -name '*.cer' -printf "%p " | sed 's/\//\\\//g')/" $ZOWE_INSTALL_ROOT/scripts/configure/zowe-install.yaml

bash $DEBUG $ZOWE_INSTALL_ROOT/scripts/configure/zowe-configure.sh

echo -n | openssl s_client -connect $ZOWE_ZOSMF_HOST:$ZOWE_ZOSMF_PORT | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $ZOWE_INSTALL_ROOT/api-mediation/keystore/localhost/certificate.cer
keytool -importcert -trustcacerts -alias ZOSMF -keyalg RSA -keystore $ZOWE_INSTALL_ROOT/api-mediation/keystore/localhost/localhost.truststore.p12 -keypass password -storepass password -storetype PKCS12 -file $ZOWE_INSTALL_ROOT/api-mediation/keystore/localhost/certificate.cer -noprompt

sed 's|//.*||' $ZOWE_INSTALL_ROOT/zlux-app-server/deploy/instance/ZLUX/serverConfig/zluxserver.json | jq ".agent.host=\"$ZOWE_ZSS_HOST\"" | jq ".agent.http.port=$ZOWE_ZSS_PORT" | sponge $ZOWE_INSTALL_ROOT/zlux-app-server/deploy/instance/ZLUX/serverConfig/zluxserver.json
sed -i 's/LAUNCH_COMPONENT_GROUPS=.*//' $ZOWE_INSTALL_ROOT/scripts/internal/run-zowe.sh
find $ZOWE_INSTALL_ROOT/ -type f -name '*.sh' -exec sh -c "chmod +x {}" \;

if [ "$1" = "--only-config" ]; then
    echo "Zowe install directory: $ZOWE_INSTALL_ROOT"
    echo "Only the installation and configuration is finished, type exit to proceed to zowe-run.sh"
    cd $ZOWE_INSTALL_ROOT
    bash
fi

cd $ZOWE_INSTALL_ROOT/scripts/internal/
bash ./run-zowe.sh
sleep infinity