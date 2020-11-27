FROM ompzowe/zowecicd-node12-java8:s390x

EXPOSE 7553/tcp
EXPOSE 7554/tcp
EXPOSE 8544/tcp

#ENV ZOWE_ZOSMF_HOST='zosmf.host.com'
#ENV ZOWE_ZSS_HOST='zss.host.com'
#ENV ZWED_agent_host='zwed.host.com'
#ENV ZOWE_EXPLORER_HOST='explorer.host.com'
#ENV ZOWE_IP_ADDRESS=0.0.0.0

ENV ZOWE_ZOSMF_PORT='11443'
#ENV ZOWE_ZSS_SERVER_PORT='00000'
#ENV ZWED_agent_http_port='00000'

#ENV PKCS11_TOKEN_NAME='ZOWE.ZSS.JWTKEYS'
#ENV PKCS11_TOKEN_LABEL='KEY_APIML'

RUN mkdir /root/zowe/utils
COPY utils/ /root/zowe/utils/
RUN cd /root/zowe/utils/autoconv && \
    npm install && \
    npm run build && \
    rm -rf node_modules src samples *.js *.json .editorconfig *ignore *.md && \
    ln -s ./autoconv/bin/autoconv ../autoconv.sh

RUN wget -q "https://zowe.jfrog.io/zowe/libs-snapshot-local/org/zowe/1.14.0-PR-1507/zowe-1.14.0-pr-1507-25-20200717032955.pax" -O /root/zowe/zowe.pax

RUN mkdir /root/zowe/samples
COPY start.sh /root/zowe/samples/


RUN cd /root/zowe/zowe-install && \
    tar -xvf ../zowe.pax --strip 1 && \
    find . -type f -iregex '.*\.\(rexx\|js\|sh\|json\|jcl\|yaml\|clist\|env\)$' -exec sh -c "conv '{}' | sponge '{}'" \; && \
    find . -type f -name '*.sh' -exec sh -c "sed -i 's/-Xquickstart//' {}" \; && \
    find . -type f -name '*.sh' -exec sh -c "sed -i 's/-ppx/-pp/' {}" \; && \
    find . -type f -name '*.sh' -exec sh -c "sed -i 's/iconv -f IBM-1047 -t IBM-850/cat/' {}" \; && \
    find . -type f -name '*.sh' -exec sh -c "chmod +x {}" \; && \
    echo "exit 0" > scripts/opercmd && \
    sed -i 's/-px //' scripts/zowe-install-zlux.sh && \
    sed -i 's/java version/openjdk version/' scripts/utils/validate-java.sh

#Convert content of pax files from ebcdic to ASCII
RUN cd /root/zowe/zowe-install/files && \
    for f in *.pax; do \
        echo "Processing $f file." && \
        rm -rf tmp && \
        mkdir tmp && \
        cd tmp && \
        pax -rf ../$f && \
        rm ../$f && \
        find . -type f -iregex '.*\.\(rexx\|js\|sh\|json\|jcl\|yaml\|clist\|html\|template\|css\|svg\|map\|gz\|env\)$' -exec sh -c "conv '{}' | sponge '{}'" \; && \
        find . -type f -name '*.sh' -exec sh -c "sed -i 's/-Xquickstart//' {}" \; && \
        pax -wf ../$f . && \
        cd .. ;  \
    done && \
    cd zlux && \
    for f in *.pax; do \
        echo "Processing $f file." &&\
        rm -rf tmp &&\
        mkdir tmp &&\
        cd tmp &&\
        pax -rf ../$f &&\
        rm ../$f &&\
        find . -type f -iregex '.*\.\(sh\)$' -exec sh -c "conv '{}' | sponge '{}'" \; && \
        find . -type f -name '*.sh' -exec sh -c "sed -i 's/-Xquickstart//' {}" \; &&\
        pax -wf ../$f . &&\
        cd .. ; \
    done && \
    rm -f /root/zowe/*.pax 


RUN /root/zowe/zowe-install/install/zowe-install.sh -i /root/zowe/install -l /root/zowe/logs && \
	bash -c "/root/zowe/install/bin/zowe-configure-instance.sh -c /root/zowe/instance"

RUN rm -f /root/zowe/*.pax && \
    rm -rf /root/zowe/zowe-install/ && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* 

RUN cd /root/zowe/install/components/explorer-ui-server && \
    rm -rf node_modules && \
    npm install --only=prod --ignore-scripts

COPY run.sh /root/zowe/
# Could be modified during runtime, back it up.
RUN cp /root/zowe/instance/instance.env /root/zowe/instance/instance.env.bkp
RUN cp /root/zowe/install/bin/zowe-setup-certificates.env /root/zowe/install/bin/zowe-setup-certificates.env.bkp

ENTRYPOINT ["/root/zowe/run.sh"]