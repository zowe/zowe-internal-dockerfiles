#!/bin/bash
mkdir utils
cp ../../../../utils/* ./utils
docker build -f Dockerfile --no-cache -t rsqa/zowe-v1-lts:testing$1 .
