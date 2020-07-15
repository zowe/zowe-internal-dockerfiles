FROM openjdk:11-jdk-slim

###
# start of from loyaltyone/docker-slim-java-node
###


###
# Dependencies for NodeJS, from: https://github.com/docker-library/buildpack-deps/blob/master/stretch/curl/Dockerfile
###

RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates curl wget \
	&& rm -rf /var/lib/apt/lists/*

RUN set -ex; \
	if ! command -v gpg > /dev/null; then \
		apt-get update; \
		apt-get install -y --no-install-recommends \
			gnupg \
			dirmngr \
		; \
		rm -rf /var/lib/apt/lists/*; \
	fi

###
# NodeJS: https://github.com/nodejs/docker-node/blob/master/8/slim/Dockerfile
###

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

# gpg keys listed at https://github.com/nodejs/node#release-team
RUN set -ex \
  && for key in \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
  ; do \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done

ENV NODE_VERSION 12.16.1

RUN buildDeps='xz-utils' \
    && ARCH= && dpkgArch="$(dpkg --print-architecture)" \
    && case "${dpkgArch##*-}" in \
      amd64) ARCH='x64';; \
      ppc64el) ARCH='ppc64le';; \
      s390x) ARCH='s390x';; \
      arm64) ARCH='arm64';; \
      armhf) ARCH='armv7l';; \
      i386) ARCH='x86';; \
      *) echo "unsupported architecture"; exit 1 ;; \
    esac \
    && set -x \
    && apt-get update && apt-get install -y $buildDeps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
    && curl -SLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
    && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
    && apt-get purge -y --auto-remove $buildDeps \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

ENV YARN_VERSION 1.5.1

RUN set -ex \
  && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
  && curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
  && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && mkdir -p /opt \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz

###
# End of NodeJS Setup
###

# Cleanup
RUN apt-get purge -y --auto-remove gnupg dirmngr

# install curl, bash and kms-env 0.3.0
RUN apt-get update && apt-get install -y --no-install-recommends groff python python-pip iproute2 && \
  pip install wheel && \
  pip install setuptools && \
  pip install awscli && \
  apt-get purge -y --auto-remove python-pip && \
  rm -rf /var/lib/apt/lists/*; \
  npm install -g kms-env@0.3.0 s3-copy@0.0.2

###
# end of from loyaltyone/docker-slim-java-node
###

EXPOSE 7553/tcp
EXPOSE 7554/tcp
EXPOSE 8544/tcp

ENV NODE_HOME='/usr/local'
ENV ZOWE_JAVA_HOME='/usr'

#ENV ZOWE_ZOSMF_HOST='zosmf.host.com'
#ENV ZOWE_ZSS_HOST='zss.host.com'
#ENV ZWED_agent_host='zwed.host.com'
#ENV ZOWE_EXPLORER_HOST='explorer.host.com'
ENV ZOWE_IP_ADDRESS=0.0.0.0

ENV ZOWE_ZOSMF_PORT='11443'
#ENV ZOWE_ZSS_SERVER_PORT='00000'
#ENV ZWED_agent_http_port='00000'

#ENV PKCS11_TOKEN_NAME='ZOWE.ZSS.JWTKEYS'
#ENV PKCS11_TOKEN_LABEL='KEY_APIML'

RUN apt-get update && \
	apt-get install -y --no-install-recommends jq moreutils pax && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean;

RUN mkdir -p /usr/share/man/man1/ && touch /usr/share/man/man1/sh.distrib.1.gz
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

RUN mkdir /root/zowe
COPY $PAX_FILE /root/zowe

RUN cd /root/zowe/ && \
    ( echo '#!/bin/sh'; echo 'tr '"'"'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'"'"' '"'"'\000\001\002\003\234\011\206\177\227\215\216\013\014\015\016\017\020\021\022\023\235\012\010\207\030\031\222\217\034\035\036\037\200\201\202\203\204\205\027\033\210\211\212\213\214\005\006\007\220\221\026\223\224\225\226\004\230\231\232\233\024\025\236\032\040\240\342\344\340\341\343\345\347\361\242\056\074\050\053\174\046\351\352\353\350\355\356\357\354\337\041\044\052\051\073\136\055\057\302\304\300\301\303\305\307\321\246\054\045\137\076\077\370\311\312\313\310\315\316\317\314\140\072\043\100\047\075\042\330\141\142\143\144\145\146\147\150\151\253\273\360\375\376\261\260\152\153\154\155\156\157\160\161\162\252\272\346\270\306\244\265\176\163\164\165\166\167\170\171\172\241\277\320\133\336\256\254\243\245\267\251\247\266\274\275\276\335\250\257\135\264\327\173\101\102\103\104\105\106\107\110\111\255\364\366\362\363\365\175\112\113\114\115\116\117\120\121\122\271\373\374\371\372\377\134\367\123\124\125\126\127\130\131\132\262\324\326\322\323\325\060\061\062\063\064\065\066\067\070\071\263\333\334\331\332\237'"'"' <$1' ) >conv && chmod +x conv && ln -s $(pwd)/conv /bin/conv && \
    rm -rf zowe && \
    mkdir zowe-install && \
    cd zowe-install && \
    tar -xvf ../zowe.pax --strip 1 && \
    find . -type f -iregex '.*\.\(rexx\|js\|sh\|json\|jcl\|yaml\|clist\|env\)$' -exec sh -c "conv '{}' | sponge '{}'" \; && \
    find . -type f -name '*.sh' -exec sh -c "sed -i 's/-Xquickstart//' {}" \; && \
    find . -type f -name '*.sh' -exec sh -c "sed -i 's/-ppx/-pp/' {}" \; && \
    find . -type f -name '*.sh' -exec sh -c "sed -i 's/iconv -f IBM-1047 -t IBM-850/cat/' {}" \; && \
    find . -type f -name '*.sh' -exec sh -c "chmod +x {}" \; && \
    sed -i 's/-px //' scripts/zowe-install-zlux.sh && \
    \
    sed -i 's/java version/openjdk version/' scripts/utils/validate-java.sh && \    
    \
    echo "exit 0" > scripts/opercmd && \
    echo "exit 0" > /bin/extattr && chmod +x /bin/extattr && \
    echo "exit 0" > /bin/ping && chmod +x  /bin/ping && \
    echo "exit 0" > /bin/oping && chmod +x  /bin/oping && \
    echo "exit 0" > /bin/onetstat && chmod +x  /bin/onetstat && \
    echo "exit 0" > /bin/chtag && chmod +x  /bin/chtag && \    
    echo 'cat $5' > /bin/iconv && chmod +x /bin/iconv && \    
    mv /usr/bin/iconv /usr/bin/iconv_ 

#Conver content of pax files from ebcdic to ASCII
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
    \
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

RUN sed -i 's/VERIFY_CERTIFICATES=true/VERIFY_CERTIFICATES=false/g' /root/zowe/install/bin/zowe-setup-certificates.env
RUN sed -i 's/ZOWE_USER_ID=ZWESVUSR/ZOWE_USER_ID=root/g' /root/zowe/install/bin/zowe-setup-certificates.env
RUN sed -i 's/ZOWE_GROUP_ID=ZWEADMIN/ZOWE_GROUP_ID=root/g' /root/zowe/install/bin/zowe-setup-certificates.env

#RUN sed -i 's/HOSTNAME=.*/HOSTNAME='"${ZOWE_EXPLORER_HOST}"'/g' /root/zowe/install/bin/zowe-setup-certificates.env
RUN sed -i 's/IPADDRESS=.*/IPADDRESS='"${ZOWE_IP_ADDRESS}"'/g' /root/zowe/install/bin/zowe-setup-certificates.env

#RUN sed -i 's/PKCS11_TOKEN_NAME=.*/PKCS11_TOKEN_NAME='"${PKCS11_TOKEN_NAME}"'/g' /root/zowe/install/bin/zowe-setup-certificates.env
#RUN sed -i 's/PKCS11_TOKEN_LABEL=.*/PKCS11_TOKEN_LABEL='"${PKCS11_TOKEN_LABEL}"'/g' /root/zowe/install/bin/zowe-setup-certificates.env

RUN cat /root/zowe/install/bin/zowe-setup-certificates.env

RUN /root/zowe/install/bin/zowe-setup-certificates.sh
RUN sed -i 's/-ebcdic//' /global/zowe/keystore/zowe-certificates.env

RUN rm -f /root/zowe/*.pax && \
    rm -rf /root/zowe/zowe-install/ && \
    apt-get purge -y pax && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* 

COPY run.sh /root/zowe/
# Could be modified during runtime, back it up.
RUN cp /root/zowe/instance/instance.env /root/zowe/instance/instance.env.bkp

ENTRYPOINT ["/root/zowe/run.sh"]
