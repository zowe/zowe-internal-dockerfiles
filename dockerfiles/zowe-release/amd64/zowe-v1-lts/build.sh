#!/bin/bash
docker build -f Dockerfile --no-cache -t zowe/docker:latest$1 .
