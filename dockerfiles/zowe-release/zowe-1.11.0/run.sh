#!/bin/bash
export PATH=$(pwd):$PATH
CERTS_DIR=/root/zowe/certs
ZOWE_INSTALL_ROOT=/root/zowe
ZOWE_INSTANCE_ROOT=/root/zowe-instance-dir

DEBUG=""
set $DEBUG

export PATH=$PATH:$NODE_HOME/bin
export _BPXK_AUTOCVT=OFF
export ZOWE_IP_ADDRESS=127.0.0.1
export ZOWE_EXPLORER_HOST=$HOSTNAME
export ZOWE_ZOSMF_HOST=$ZOWE_ZOSMF_HOST
export ZOWE_ZOSMF_PORT=$ZOWE_ZOSMF_PORT
export USER=$(whoami)
export userid=$USER

export LINUX_HOST='waldevgizaud001.dev.rocketsoftware.com'

echo "STart testing"
ls
echo $ZOWE_INSTALL_ROOT
echo "Installation root $ZOWE_INSTALL_ROOT" 
if [ "$1" = "--only-install" ]; then
    echo "Only the installation is finished, type exit to proceed to configuration"#
    cd $ZOWE_INSTALL_ROOT
    bash
fi

#sed -i 's/gatewayPort=7554/gatewayPort=60004/' $ZOWE_INSTALL_ROOT/scripts/configure/zowe-install.yaml
#sed -i "s/externalCertificate=/externalCertificate=$(echo "$CERTS_DIR/server.p12" |  sed 's/\//\\\//g')/" $ZOWE_INSTALL_ROOT/scripts/configure/zowe-install.yaml
#sed -i 's/externalCertificateAlias=/externalCertificateAlias=apiml/' $ZOWE_INSTALL_ROOT/scripts/configure/zowe-install.yaml
#sed -i "s/externalCertificateAuthorities=/externalCertificateAuthorities=$(find $CERTS_DIR -name '*.cer' -printf "%p " | sed 's/\//\\\//g')/" $ZOWE_INSTALL_ROOT/scripts/configure/zowe-install.yaml

#bash $DEBUG $ZOWE_INSTALL_ROOT/scripts/configure/zowe-configure.sh

#ZOSMF_CERT_FILE=$ZOWE_INSTALL_ROOT/components/api-mediation/keystore/localhost/zosmf.cer
#ZOWE_P12_FILE=$ZOWE_INSTALL_ROOT/components/api-mediation/keystore/localhost/localhost.truststore.p12
#echo "Downloading z/OSMF certificate from $ZOWE_ZOSMF_HOST:$ZOWE_ZOSMF_PORT to $ZOSMF_CERT_FILE"
#echo -n | openssl s_client -connect $ZOWE_ZOSMF_HOST:$ZOWE_ZOSMF_PORT | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $ZOSMF_CERT_FILE
#echo "Importing z/OSMF certificate '$ZOSMF_CERT_FILE' into '$ZOWE_P12_FILE'"
#keytool -importcert -trustcacerts -alias ZOSMF -keyalg RSA -keystore $ZOWE_P12_FILE -keypass password -storepass password -storetype PKCS12 -file $ZOSMF_CERT_FILE -noprompt

#Change this to match new installation paths don't know what about means lmaop'

#sed 's|//.*||' $ZOWE_INSTALL_ROOT/zlux-app-server/deploy/instance/ZLUX/serverConfig/zluxserver.json | jq ".agent.host=\"$ZOWE_ZSS_HOST\"" | jq ".agent.http.port=$ZOWE_ZSS_PORT" | sponge $ZOWE_INSTALL_ROOT/zlux-app-server/deploy/instance/ZLUX/serverConfig/zluxserver.json
#sed 's|//.*||' /root/zowe/instance/workspace/app-server/serverConfig/server.json | jq ".node.https.certificates=\"/global/zowe/keystore/localhost/localhost.keystore.cer\"" | jq ".node.https.certificateAuthorities=\"/global/zowe/keystore/local_ca/localca.cer\"" | sponge /root/zowe/instance/workspace/app-server/serverConfig/server.json

#enforce components to be started
#sed -i 's/LAUNCH_COMPONENT_GROUPS=.*/LAUNCH_COMPONENT_GROUPS='"$LAUNCH_COMPONENT_GROUPS"'/' $ZOWE_INSTANCE_ROOT/instance.env
#ZOWE_EXPLORER_FRAME_ANCESTORS="${ZOWE_EXPLORER_HOST}:*,${ZOWE_IP_ADDRESS}:*"
#remove ebcdic suffinx from certname - KEYSTORE_CERTIFICATE=${KEYSTORE_DIRECTORY}/${KEY_ALIAS}/${KEY_ALIAS}".keystore.cer-ebcdic"
sed -i 's/-ebcdic//' /global/zowe/keystore/zowe-certificates.env
sed -i -e 's/ZOWE_EXPLORER_FRAME_ANCESTORS="${ZOWE_EXPLORER_HOST}:*,${ZOWE_IP_ADDRESS}:*"/ZOWE_EXPLORER_FRAME_ANCESTORS="${ZOWE_EXPLORER_HOST}:*,${ZOWE_IP_ADDRESS}:*,${LINUX_HOST}:*"/g' /root/zowe/instance/instance.env

cat /root/zowe/instance/instance.env


find $ZOWE_INSTALL_ROOT/ -type f -name '*.sh' -exec sh -c "chmod +x {}" \;

if [ "$1" = "--only-config" ]; then
    echo "Zowe install directory: $ZOWE_INSTALL_ROOT"
    echo "Zowe instance directory: $ZOWE_INSTANCE_ROOT"
    echo "Only the installation and configuration is finished, type exit to proceed to zowe-run.sh"
    cd $ZOWE_INSTALL_ROOT
    bash
fi

cd $ZOWE_INSTANCE_ROOT/bin/internal/
ls /root/zowe/instance/bin/internal/run-zowe.sh
bash /root/zowe/instance/bin/internal/run-zowe.sh
sleep infinity

