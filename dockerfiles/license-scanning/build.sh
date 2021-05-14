
mkdir -p build/ && cd build && rm -rf zowe-dependency-scan-pipeline && git clone https://github.com/zowe/zowe-dependency-scan-pipeline && cd ..
#!/bin/bash
rsync -av --progress build/zowe-dependency-scan-pipeline/licenses/dependency-scan include/ --delete --exclude .git --exclude build --exclude lib --exclude node_modules --exclude yarn.lock
rsync -av --progress build/zowe-dependency-scan-pipeline/licenses/LicenseFinder include/ --delete --exclude .git --exclude ci
rsync -av --progress build/zowe-dependency-scan-pipeline/licenses/resources include/ --delete --exclude .git --exclude ci
