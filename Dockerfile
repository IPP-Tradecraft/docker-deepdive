FROM ubuntu:trusty
MAINTAINER Scott Phillpott <scott@phillpott.com>, Ahmed Masud <ahmed.masud@trustifier.com>

ENV DEBIAN_FRONTEND noninteractive

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup
RUN echo "Acquire::http {No-cache=True;};" > /etc/apt/apt.conf.d/no-cache

RUN apt-get update && apt-get install -yq \
	supervisor \
	screen \
	eog \
	python \
	build-essential \
	make \
	gcc \
	libtool \
	pandoc \
	openssh-server \
	python-dev \
	python-setuptools \
	python-numpy \
	python-matplotlib \
	pango-graphite \
	gnuplot-x11 \
	postgresql   \
	postgresql-contrib \
	python-pip \
	libnuma-dev

RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN dpkg-reconfigure dash

RUN pip install pypandoc
RUN pip install inotify
RUN apt-get -yq install curl
RUN apt-get -yq install bsdmainutils 
RUN apt-get -yq install git software-properties-common python3
RUN apt-add-repository -y ppa:webupd8team/java
RUN apt-get -yq update
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen   true | debconf-set-selections
RUN apt-get -yq install oracle-java8-installer

RUN mkdir -p /usr/local/bin && pushd /usr/local/bin			  && \
	echo '#!/bin/bash'			  	 > getdeepdive.sh && \
	echo export DEBIAN_FRONTEND=noninteractive 	>> getdeepdive.sh && \
	curl -fsSL git.io/getdeepdive | sed -e '/^#!/d'	>> getdeepdive.sh && \
	chmod a+x /usr/local/bin/getdeepdive.sh 			  && \
	:
	
RUN sed -i -e '/^%sudo/s/ALL[ \t]*$/NOPASSWD: ALL/'  /etc/sudoers
RUN useradd -c "Deep Diver,,," -m -s /bin/bash --groups sudo deepdiver && \
	echo deepdiver:${DD_PASSWORD}  | chpasswd -c SHA512

COPY run-postgresql.sh /usr/bin
COPY supervisor-postgresql.conf supervisor-sshd.conf /etc/supervisor/conf.d/
COPY fix-postgres-settings.sh /tmp/

RUN chmod a+x /tmp/fix-postgres-settings.sh 
RUN /tmp/fix-postgres-settings.sh
RUN mkdir /var/run/sshd

USER deepdiver
WORKDIR /home/deepdiver
RUN echo PATH="/home/deepdiver/local/bin:$PATH" >> ~/.bashrc
RUN id 
# RUN USER=deepdiver getdeepdive.sh postgres
RUN USER=deepdiver getdeepdive.sh deepdive_from_release
RUN USER=deepdiver getdeepdive.sh deepdive_examples_tests
RUN USER=deepdiver getdeepdive.sh spouse_example
 
USER root
ENTRYPOINT [ "/usr/bin/supervisord" ]

