#!/bin/bash
docker build -f Dockerfile.manual --no-cache -t zowe/docker:latest$1 .
