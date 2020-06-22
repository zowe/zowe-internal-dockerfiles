#!/bin/bash
# Example usage:
# sudo ./copy_jwt_to_zss.sh -u TS6330 -rd /u/ts6330/dkr_tmp -c exciting_bhaskara
# TODO: add comment for flags
TEMP_DIR=/tmp/
REMOTE_DIR=/tmp/
OUT_FILE_NAME=jwtsecret.p12
ZSS_HOST=
ZSS_USER=REMOTE_USER
CONTAINER_NAME=container_name

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
    * )                   echo "Invalid command: $1"
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