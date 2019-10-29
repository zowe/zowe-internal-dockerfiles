#!/bin/bash
export PATH=$(pwd):$PATH
WORK_DIR=$(pwd)
ZOWE_INSTALL_ROOT=/root/zowe/1.6.0

DEBUG=""
set $DEBUG

rm -rf zowe
mkdir zowe
cd zowe
tar -xvf ../*.pax --strip 1
find . -type f -iregex '.*\.\(rexx\|js\|sh\|json\|jcl\|yaml\|clist\)$' -exec sh -c "conv {} > {}_ ; mv {}_ {}" \;
find . -type f -name '*.sh' -exec sh -c "sed -i 's/-Xquickstart//' {}" \;
find . -type f -name '*.sh' -exec sh -c "sed -i 's/-ppx/-pp/' {}" \;
find . -type f -name '*.sh' -exec sh -c "sed -i 's/iconv -f IBM-1047 -t IBM-850/cat/' {}" \;
find . -type f -name '*.sh' -exec sh -c "chmod +x {}" \;
sed -i 's/-px //' scripts/zlux-install-script.sh
sed -i 's/java version/openjdk version/' scripts/utils/validateJava.sh
echo "exit 0" > scripts/opercmd

cd files
for f in *.pax; do
    echo "Processing $f file.";
    rm -rf tmp
    mkdir tmp
    cd tmp
    pax -rf ../$f
    rm ../$f
    find . -type f -iregex '.*\.\(rexx\|js\|sh\|json\|jcl\|yaml\|clist\|html\|template\|css\|svg\|map\|gz\)$' -exec sh -c "conv {} > {}_ ; mv {}_ {}" \;
    find . -type f -name '*.sh' -exec sh -c "sed -i 's/-Xquickstart//' {}" \;
    pax -wf ../$f .
    cd ..
done

cd zlux
for f in *.pax; do
    echo "Processing $f file.";
    rm -rf tmp
    mkdir tmp
    cd tmp
    pax -rf ../$f
    rm ../$f
    find . -type f -exec sh -c "conv '{}' | sponge '{}'" \;
    find . -type f -name '*.sh' -exec sh -c "sed -i 's/-Xquickstart//' {}" \;
    pax -wf ../$f .
    cd ..
done
cd ..
cd ..

export PATH=$PATH:$NODE_HOME/bin
export _BPXK_AUTOCVT=OFF

cd install
bash $DEBUG zowe-install.sh -I
rm /root/.zowe_profile
