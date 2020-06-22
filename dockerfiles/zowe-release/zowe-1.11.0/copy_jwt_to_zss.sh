#!/bin/bash
# Example usage:
# sudo ./copy_jwt_to_zss.sh -c exciting_bhaskara -u MYTSO -rd /u/mytso/docker_tmp
TEMP_DIR=/tmp/
REMOTE_DIR=/tmp/
OUT_FILE_NAME=jwtsecret.p12
ZSS_HOST=
ZSS_USER=REMOTE_USER
CONTAINER_NAME=container_name

function usage {
    echo "This script is for transferring the APIML JWT public key created during certificate generation to the Zowe ZSS host."
    echo ""
    echo "usage: sudo copy_jwt_to_zss.sh -[OPTION]"
    echo "or: sudo copy_jwt_to_zss.sh --[OPTION]"
    echo ""
    echo "  Options:"
    echo "     -c, --container   - name of zowe docker container. run 'docker ps' for info"
    echo "     -h, --host        - Zowe ZSS host address. default: ZOWE_ZSS_HOST environment variable from container"
    echo "     -o, --out         - nanme of output file to be copied to remote directory. default: jwtsecret.p12"
    echo "     -u, --username    - scp username for connection to remote (Zowe ZSS) host. default: REMOTE_USER" 
    echo "     -td, --tempdir    - directory to store temp files from docker container. default: /tmp/"
    echo "     -rd, --remotedir  - directory to copy APIML JWT public key to on remote host. default: /tmp/"
    echo ""
}

while [ "$1" != "" ]; do
  case $1 in
    -c | --container )    shift
                          CONTAINER_NAME=$1
                          ;;       
    -td | --tempdir )     shift
                          TEMP_DIR=$1
                          ;;               
    -rd | --remotedir )   shift
                          REMOTE_DIR=$1
                          ;;
    -o | --out )          shift
                          OUT_FILE_NAME=$1
                          ;;
    -h | --host )         shift
                          ZSS_HOST=$1
                          ;;
    -u | --username )     shift
                          ZSS_USER=$1
                          ;;
    --help )              usage
                          exit
                          ;;
    * )                   echo "Invalid command: $1"
                          usage
                          exit 1
  esac
  shift
done

FULL_LOCAL_OUT_PATH="${TEMP_DIR}${OUT_FILE_NAME}"
echo "OUT PATH=${FULL_LOCAL_OUT_PATH}"
docker cp $CONTAINER_NAME:/global/zowe/keystore/localhost/localhost.keystore.jwtsecret.p12 $FULL_LOCAL_OUT_PATH
if [ -z "$ZSS_HOST" ]; then
  ZSS_HOST=$(docker exec $CONTAINER_NAME bash -c 'echo $ZOWE_ZSS_HOST')
fi
echo "Initiating scp file transfer to ${ZSS_USER}@${ZSS_HOST}"  
if ! scp $FULL_LOCAL_OUT_PATH $ZSS_USER@$ZSS_HOST:$REMOTE_DIR/$OUT_FILE_NAME ; then
  echo "Unable to write ${ZSS_HOST}:${REMOTE_DIR}/${OUT_FILE_NAME}. File may already exist or user may have insufficient write permissions."
fi
rm -f $FULL_LOCAL_OUT_PATH