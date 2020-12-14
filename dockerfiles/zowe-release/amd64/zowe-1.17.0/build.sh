#!/bin/bash
mkdir utils
cp -r ../../../../utils/* ./utils
docker build -f Dockerfile --no-cache -t ompzowe/server-bundle:testing$1 .
