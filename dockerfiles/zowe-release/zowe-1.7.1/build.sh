#!/bin/bash
docker build -t zowe/docker:1.7.1 -t zowe/docker:latest -t  vvvlc/zowe:1.7.1$1 -t vvvlc/zowe:latest .
