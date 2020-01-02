#!/bin/bash
export PATH=$(pwd):$PATH
CERTS_DIR=/root/zowe/certs
if [ ! -d $CERTS_DIR ]; then
    mkdir -p /root/zowe/certs
fi

export ZOWE_INSTALL_ROOT=/root/zowe/current
export ZOWE_INSTANCE_ROOT=/root/zowe-instance-dir

DEBUG=""
set $DEBUG

export PATH=$PATH:$NODE_HOME/bin
export _BPXK_AUTOCVT=OFF
#export ZOWE_IP_ADDRESS=127.0.0.1
touch ~/.zowe_profile
export ZOWE_IPADDRESS=127.0.0.1
echo "export ZOWE_IPADDRESS=127.0.0.1" >> ~/.zowe_profile
export ZOWE_EXPLORER_HOST=$HOSTNAME
echo "export ZOWE_EXPLORER_HOST=$HOSTNAME" >> ~/.zowe_profile

FAKE_OSMF=0
if [ "$ZOWE_ZOSMF_HOST" = "" ] ; then
    FAKE_OSMF=1
    export ZOWE_ZOSMF_HOST=$HOSTNAME
else
    export ZOWE_ZOSMF_HOST=$ZOWE_ZOSMF_HOST
fi
export ZOWE_ZOSMF_PORT=$ZOWE_ZOSMF_PORT

env

# parser parameters from command line
TEMP=$(getopt -o icpr --long only-install,only-config,post-start,regenerate-certificates,help -- "$@")
eval set -- "$TEMP"

while true ; do
    case "$1" in
        --only-install)
            export ONLY_INSTAL=1 ;;
        --only-config)
            export ONLY_CONFIG=1 ;;
        --post-start)
            export POST_START=1 ;;
        --regenerate-certificates)
            export REGENERATE_CERTIFICATES=1 ;;
        --help)
            echo -e "available options to start container are:\n\t--only-install\tpause after installation\n\t--only-config\tpause after configuration\n\t--post-start\tpause after zowe start\n\t--regenerate-certificates\tenforce to regenerate certificates"; exit 255 ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
    shift
done

echo "Installation root $ZOWE_INSTALL_ROOT" 
if [ "$ONLY_INSTAL" = "1" ]; then
    echo "Only the installation is finished, type exit to proceed to configuration"
    cd $ZOWE_INSTALL_ROOT
    bash
fi

#customize zowe-install.yaml
#sed -i 's/gatewayPort=7554/gatewayPort=60004/' $ZOWE_INSTALL_ROOT/scripts/configure/zowe-install.yaml
#setup external certificates if they are available
if [ -e "$CERTS_DIR/server.p12" ]; then
    sed -i "s/externalCertificate=/externalCertificate=$(echo "$CERTS_DIR/server.p12" |  sed 's/\//\\\//g')/" $ZOWE_INSTALL_ROOT/scripts/configure/zowe-install.yaml
    sed -i 's/externalCertificateAlias=/externalCertificateAlias=apiml/' $ZOWE_INSTALL_ROOT/scripts/configure/zowe-install.yaml
fi
if ls $CERTS_DIR/*.cer 1> /dev/null 2>&1; then
    sed -i "s/externalCertificateAuthorities=/externalCertificateAuthorities=$(find $CERTS_DIR -name '*.cer' -printf "%p " | sed 's/\//\\\//g')/" $ZOWE_INSTALL_ROOT/scripts/configure/zowe-install.yaml
fi

#configure zowe
bash $DEBUG $ZOWE_INSTALL_ROOT/scripts/configure/zowe-configure.sh

#start fakeOSMF
if [ "$FAKE_OSMF" = "1" ] ; then
    echo preparing certificates for fakeOSMF
    FAKE_OSMF_CA=/root/zowe/tools/fakeosmf.pem
    openssl pkcs12 -in $ZOWE_INSTALL_ROOT/components/api-mediation/keystore/localhost/localhost.keystore.p12 -passin pass:password -nokeys -chain | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $FAKE_OSMF_CA
    echo Starting fakeOSMF on port $ZOWE_ZOSMF_PORT
    /root/zowe/tools/fakeosmf.py \
        -d \
        -p $ZOWE_ZOSMF_PORT \
        -k $ZOWE_INSTALL_ROOT/components/api-mediation/keystore/localhost/localhost.keystore.key \
        -c $FAKE_OSMF_CA \
        | tee /root/zowe/tools/fakeosmf.log &
    #wait until it is ready
    echo "Waiting fakeOSMF to complete intialization"
    export ZOWE_ZOSMF_HOST=$HOSTNAME    
    until  echo -n |  openssl s_client -connect $ZOWE_ZOSMF_HOST:$ZOWE_ZOSMF_PORT ; do sleep 1 ; done  > /dev/null 2>&1
    echo "fakeOSMF is ready"
fi

#configure refresh-static-apis.sh
#sed 's/\*\*ZOWE_INSTALL_ROOT\*\*/'$(echo $ZOWE_INSTALL_ROOT | sed 's/\//\\\//g')'/g' -i /root/zowe/tools/refresh-static-apis.sh
#setup cert file for tools/refresh-static-apis.sh
openssl pkcs12 -in $ZOWE_INSTALL_ROOT/components/api-mediation/keystore/localhost/localhost.keystore.p12 -out $ZOWE_INSTALL_ROOT/components/api-mediation/keystore/localhost/localhost.keystore.pem -passin pass:password -nodes -clcerts

#obtaining z/OSMF certificate
ZOSMF_CERT_FILE=$ZOWE_INSTALL_ROOT/components/api-mediation/keystore/localhost/zosmf.cer
ZOWE_P12_FILE=$ZOWE_INSTALL_ROOT/components/api-mediation/keystore/localhost/localhost.truststore.p12
echo "Downloading z/OSMF certificate from $ZOWE_ZOSMF_HOST:$ZOWE_ZOSMF_PORT to $ZOSMF_CERT_FILE"
echo -n | openssl s_client -connect $ZOWE_ZOSMF_HOST:$ZOWE_ZOSMF_PORT | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $ZOSMF_CERT_FILE
echo "Importing z/OSMF certificate '$ZOSMF_CERT_FILE' into '$ZOWE_P12_FILE'"
keytool -importcert -trustcacerts -alias ZOSMF -keyalg RSA -keystore $ZOWE_P12_FILE -keypass password -storepass password -storetype PKCS12 -file $ZOSMF_CERT_FILE -noprompt

#configure ZSS_HOST in zluxserver.json
sed 's|//.*||' $ZOWE_INSTALL_ROOT/zlux-app-server/deploy/instance/ZLUX/serverConfig/zluxserver.json | jq ".agent.host=\"$ZOWE_ZSS_HOST\"" | jq ".agent.http.port=$ZOWE_ZSS_PORT" | sponge $ZOWE_INSTALL_ROOT/zlux-app-server/deploy/instance/ZLUX/serverConfig/zluxserver.json

#enforce components to be started
#sed -i 's/LAUNCH_COMPONENT_GROUPS=.*/LAUNCH_COMPONENT_GROUPS='"$LAUNCH_COMPONENT_GROUPS"'/' $ZOWE_INSTANCE_ROOT/instance.env
sed -i 's/LAUNCH_COMPONENT_GROUPS=.*//' $ZOWE_INSTALL_ROOT/scripts/internal/run-zowe.sh

#remove ebcdic suffinx from certname - KEYSTORE_CERTIFICATE=${KEYSTORE_DIRECTORY}/${KEY_ALIAS}/${KEY_ALIAS}".keystore.cer-ebcdic"
sed -i 's/-ebcdic//'  $ZOWE_INSTALL_ROOT/scripts/internal/run-zowe.sh

find $ZOWE_INSTALL_ROOT/ -type f -name '*.sh' -exec sh -c "chmod +x {}" \;

if [ "$ONLY_CONFIG" = "1" ]; then
    echo "Zowe install directory: $ZOWE_INSTALL_ROOT"
    echo "Only the installation and configuration is finished, type exit to proceed to zowe-run.sh"
    cd $ZOWE_INSTALL_ROOT
    bash
fi

#start zowe
cd $ZOWE_INSTALL_ROOT/scripts/internal/
bash ./run-zowe.sh

if [ "$POST_START" = "1" ]; then
    echo "Zowe install directory: $ZOWE_INSTALL_ROOT"
    echo "Zowe is started, when you exit infinite loop starts."
    cd $ZOWE_INSTALL_ROOT
    bash
fi
sleep infinity