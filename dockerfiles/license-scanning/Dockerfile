# Jenkins Alpine comes with jenkins agent + java8, user jenkins (1000)
FROM jenkins/jnlp-slave:alpine

#####################################################
# version the Dockerfile, so we can do release bump
LABEL version="0.0.1"

USER root

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk update && apk upgrade
RUN apk add curl
RUN apk add bash=5.0.11-r1
RUN apk add nodejs=12.14.1-r0
RUN apk add npm=12.14.1-r0
RUN apk add python zip unzip wget

############# From Ruby Dockerfile - the apk packages are old


# skip installing gem documentation
RUN mkdir -p /usr/local/etc \
	&& { \
	echo 'install: --no-document'; \
	echo 'update: --no-document'; \
	} >> /usr/local/etc/gemrc

ENV RUBY_MAJOR 2.6
ENV RUBY_VERSION 2.6.3
ENV RUBY_DOWNLOAD_SHA256 11a83f85c03d3f0fc9b8a9b6cad1b2674f26c5aaa43ba858d4b0fcc2b54171e1

# some of ruby's build scripts are written in ruby
#   we purge system ruby later to make sure our final image uses what we just built
# readline-dev vs libedit-dev: https://bugs.ruby-lang.org/issues/11869 and https://github.com/docker-library/ruby/issues/75
RUN set -ex \
	\
	&& apk add --no-cache --virtual .ruby-builddeps \
	autoconf \
	bison \
	bzip2 \
	bzip2-dev \
	ca-certificates \
	coreutils \
	dpkg-dev dpkg \
	gcc \
	gdbm-dev \
	glib-dev \
	libc-dev \
	libffi-dev \
	libxml2-dev \
	libxslt-dev \
	linux-headers \
	make \
	ncurses-dev \
	libressl \
	libressl-dev \
	procps \
	readline-dev \
	ruby \
	tar \
	xz \
	yaml-dev \
	zlib-dev \
	\
	&& wget --no-check-certificate -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz" \
	&& echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum -c - \
	\
	&& mkdir -p /usr/src/ruby \
	&& tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1 \
	&& rm ruby.tar.xz

# https://github.com/docker-library/ruby/issues/196
# https://bugs.ruby-lang.org/issues/14387#note-13 (patch source)
# https://bugs.ruby-lang.org/issues/14387#note-16 ("Therefore ncopa's patch looks good for me in general." -- only breaks glibc which doesn't matter here)
COPY include/0001-thread_pthread.c-make-get_main_stack-portable-on-lin.patch /usr/src/ruby/thread-stack-fix.patch

RUN cd /usr/src/ruby \
	&& echo '3ab628a51d92fdf0d2b5835e93564857aea73e0c1de00313864a94a6255cb645 *thread-stack-fix.patch' | sha256sum -c - \
	&& patch -p1 -i thread-stack-fix.patch \
	&& rm thread-stack-fix.patch \
	\
	# hack in "ENABLE_PATH_CHECK" disabling to suppress:
	#   warning: Insecure world writable dir
	&& { \
	echo '#define ENABLE_PATH_CHECK 0'; \
	echo; \
	cat file.c; \
	} > file.c.new \
	&& mv file.c.new file.c \
	\
	&& autoconf \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	# the configure script does not detect isnan/isinf as macros
	&& export ac_cv_func_isnan=yes ac_cv_func_isinf=yes \
	&& ./configure \
	--build="$gnuArch" \
	--disable-install-doc \
	--enable-shared \
	&& make -j "$(nproc)" \
	&& make install \
	\
	&& runDeps="$( \
	scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
	| tr ',' '\n' \
	| sort -u \
	| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apk add --no-network --virtual .ruby-rundeps $runDeps \
	bzip2 \
	ca-certificates \
	libffi-dev \
	procps \
	yaml-dev \
	zlib-dev \
	&& apk del --no-network .ruby-builddeps \
	&& cd / \
	&& rm -r /usr/src/ruby \
	# rough smoke test
	&& ruby --version && gem --version && bundle --version 

RUN which bundle
# install things globally, for great justice
# and don't create ".bundle" in all our apps
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
	BUNDLE_SILENCE_ROOT_WARNING=1 \
	BUNDLE_APP_CONFIG="$GEM_HOME"
# path recommendation: https://github.com/bundler/bundler/pull/6469#issuecomment-383235438
ENV PATH $GEM_HOME/bin:$BUNDLE_PATH/gems/bin:$PATH
# adjust permissions of a few directories for running "gem install" as an arbitrary user
RUN mkdir -p "$GEM_HOME" && chmod 777 "$GEM_HOME"
# (BUNDLE_PATH = GEM_HOME, no need to mkdir/chown both)

########## End Ruby Dockerfile

########## Alpine - Ruby Dependency  Nokogiri Requirements

RUN apk add --update-cache postgresql-client nodejs \
	libffi-dev readline sqlite build-base postgresql-dev \
	libc-dev linux-headers libxml2-dev libxslt-dev readline-dev gcc libc-dev \
	&& rm -rf /var/cache/apk/

########### End dependencies for Nokogiri

RUN mkdir -p /home/jenkins && chown -R jenkins:jenkins /home/jenkins
RUN	mkdir /report && chown -R jenkins:jenkins /report   

USER jenkins 

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
	mv dependency-check /home/jenkins/                                       	&& \                                    
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

