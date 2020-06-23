#!/bin/bash

sed -i 's/LAUNCH_COMPONENT_GROUPS=.*/LAUNCH_COMPONENT_GROUPS='"${LAUNCH_COMPONENT_GROUPS}"'/g' /root/zowe/instance/instance.env
bash /root/zowe/instance/bin/internal/run-zowe.sh
sleep infinity

