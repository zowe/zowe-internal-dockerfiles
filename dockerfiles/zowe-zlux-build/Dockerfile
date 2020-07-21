FROM ubuntu:latest

RUN apt-get update \
    && export DEBIAN_FRONTEND="noninteractive" \
    && apt-get install -yq apt-utils \
    && apt-get install -yq locales bash git curl wget sshpass ant-contrib python3 python3-pip \
        build-essential docker.io gnupg unzip

RUN wget -qO- https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get update && apt-get install -yq nodejs

RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && chmod +x Miniconda3-latest-Linux-x86_64.sh \
    && ./Miniconda3-latest-Linux-x86_64.sh -b

RUN ~/miniconda3/bin/conda install conda-build

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN rm -rf /var/lib/apt/lists/*

RUN pip3 install -U --no-cache-dir \
        pip setuptools virtualenv pytest requests selenium ebcdic pytest-json-report pytest-html \
        allure-pytest fabric3 pillow lxml

RUN npm install -g mocha mocha-jenkins-reporter mocha-multi-reporters mochawesome \
    && rm -rf /root/.npm
RUN cd /usr/bin && curl -fL https://getcli.jfrog.io | sh

RUN curl -L "https://dl.bintray.com/jeremy-long/owasp/dependency-check-5.2.4-release.zip" \
        -o owasp-dependency-check.zip \
    && mkdir /opt/owasp \
    && unzip owasp-dependency-check.zip -d /opt/owasp \
    && rm owasp-dependency-check.zip \
    && ln -s /opt/owasp/dependency-check/bin/dependency-check.sh /usr/bin/owasp-dep-check \
    && owasp-dep-check --updateonly


RUN echo 'root:root' | chpasswd \
    && mkdir ~/.ssh \
    && ssh-keyscan github.com >> ~/.ssh/known_hosts
