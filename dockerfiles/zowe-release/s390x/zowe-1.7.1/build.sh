#!/bin/bash
docker build -t zowe/docker:1.7.1-s390x -t zowe/docker:latest-s390x -t  vvvlc/zowe:1.7.1-s390x -t vvvlc/zowe:latest-s390x .
