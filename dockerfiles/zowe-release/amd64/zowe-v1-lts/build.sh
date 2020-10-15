#!/bin/bash
mkdir utils
cp -r ../../../../utils/* ./utils
docker build -f Dockerfile --no-cache -t ompzowe/zowe-v1-lts:testing$1 .
