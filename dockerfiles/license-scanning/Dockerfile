# Set base image as Debian Buster w/ Packaged Ruby
FROM ruby:2.6.5-buster

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins user" -d /home/${user} -u ${uid} -g ${gid} -m ${user}

#####################################################
# version the Dockerfile, so we can do release bump
LABEL version="0.0.2"

USER root

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y curl bash python zip unzip wget software-properties-common
RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add -
RUN add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get update -y && apt-get install -y nodejs adoptopenjdk-8-hotspot


########## Alpine - Ruby Dependency  Nokogiri Requirements

RUN apt-get install -y build-essential patch ruby-dev zlib1g-dev liblzma-dev

########### End dependencies for Nokogiri

RUN mkdir -p /home/jenkins && chown -R jenkins:jenkins /home/jenkins
RUN	mkdir /report && chown -R jenkins:jenkins /report   

USER jenkins 

WORKDIR /home/jenkins

RUN mkdir -p /home/jenkins/.npm_global
ENV NPM_CONFIG_PREFIX=/home/jenkins/.npm-global
ENV PATH=$PATH:/home/jenkins/.npm-global/bin
ENV PATH=$GEM_HOME/bin:$BUNDLE_PATH/gems/bin:$PATH

RUN npm install -g yarn

ENV owasp_version=5.1.0
ENV owasp_dc_download=https://dl.bintray.com/jeremy-long/owasp

RUN file="dependency-check-${owasp_version}-release.zip"                         		&& \
	wget "$owasp_dc_download/$file"                                             && \
	unzip ${file}                                                           	&& \
	rm ${file}                                                             	 	&& \
	chown -R jenkins:jenkins /home/jenkins/dependency-check                  

RUN gem install bundle-audit  
RUN gem cleanup

COPY --chown=jenkins:jenkins include/LicenseFinder /home/jenkins/LicenseFinder

WORKDIR /home/jenkins/LicenseFinder
RUN gem install bundler:2.0.1
RUN git init && git add .
RUN bundle install -j4 
RUN rake install

COPY --chown=jenkins:jenkins include/dependency-scan /home/jenkins/dependency-scan
WORKDIR /home/jenkins/dependency-scan
RUN yarn install && yarn build
WORKDIR /home/jenkins

USER root
RUN curl -fL https://getcli.jfrog.io | sh && chmod 775 jfrog && mv jfrog /usr/local/bin

ARG VERSION=3.28
COPY include/jenkins-agent-entrypoint /usr/local/bin/jenkins-agent-entrypoint
RUN curl --create-dirs -fsSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
	&& chmod 755 /usr/share/jenkins \
	&& chmod 644 /usr/share/jenkins/slave.jar

ENTRYPOINT [ "jenkins-agent-entrypoint" ]

