FROM ubuntu:18.04

#####################################################
# version the Dockerfile, so we can do release bump
LABEL version="0.0.1"

#####################################################
# Set /bin/sh to use bash instead of dash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
#
#####################################################

#####################################################
# Environment Variables
ENV DEBIAN_FRONTEND noninteractive
ENV DEFAULT_NODE_VERSION 8.16.1
ENV NVM_VERSION 0.34.0
ENV NVM_DIR /usr/local/nvm
ENV CHECKLINK_VERSION 4_81
ENV DOCKER_VERSION 18.09.0
ENV DOCKER_CHANNEL stable
ENV DOCKER_ARCH x86_64
ENV DIND_COMMIT 52379fa76dee07ca038624d639d9e14f4fb719ff
#
#####################################################

RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential libssl-dev curl wget rsync pax sshpass bzip2 jq locales  \
    software-properties-common \
    cpanminus  \
    # Keyring dependencies for Chrome or keytar
    gnome-keyring libsecret-1-dev dbus dbus-user-session dbus-x11 \
    libdbus-glib-1-2 \
    iptables ca-certificates \
    # Remove expect once CLI is converted to single shared pipeline
    expect
    # bring this back in once image is stable 
    #&& rm -rf /var/lib/apt/lists/*
# RUN apt-get install -y  <>
#####################################################
# configure locale
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && /usr/sbin/locale-gen
#
#####################################################
RUN apt-get install -y gpg-agent
RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add -
RUN add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
RUN apt-get update && apt-get install --no-install-recommends -y adoptopenjdk-8-hotspot


RUN mkdir -p $NVM_DIR \
    && curl https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash \
    && source $NVM_DIR/nvm.sh \
    && nvm install $DEFAULT_NODE_VERSION \
    && nvm install 10.* \
    && nvm install 12.* \
    && nvm alias default ${DEFAULT_NODE_VERSION} \
    && nvm use default

RUN apt-get install -y git
RUN curl -fL https://getcli.jfrog.io | sh && mv jfrog /usr/local/bin

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$DEFAULT_NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$DEFAULT_NODE_VERSION/bin:$PATH