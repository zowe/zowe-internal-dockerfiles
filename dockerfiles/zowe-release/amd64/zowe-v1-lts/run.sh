#!/bin/bash

cp /root/zowe/instance/instance.env.bkp /root/zowe/instance/instance.env

input="/root/zowe/instance/instance.env.bkp"
while read -r line
do
  test -z "${line%%#*}" && continue      # skip line if first char is #
  key=${line%%=*}
  if [ -n "${!key}" ]
  then
      sed -i 's/'${key}'=.*/'${key}'='"${!key}"'/g' /root/zowe/instance/instance.env
  fi
done < "$input"

bash /root/zowe/instance/bin/internal/run-zowe.sh
sleep infinity
