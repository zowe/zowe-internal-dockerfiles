#!/bin/bash
mkdir utils
cp -r ../../../../utils/* ./utils
docker build -f Dockerfile --no-cache -t rsqa/zowe-v1-lts:testing$1 .
