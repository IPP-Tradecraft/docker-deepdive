FROM ubuntu:trusty
MAINTAINER Scott Phillpott <scott@phillpott.com>

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
	python \
	build-essential \
	make \
	gcc \
	libtool \
	python-dev \
	python-setuptools \
	python-numpy \
	python-matplotlib \
	pango-graphite \
	gnuplot-x11 \
	postgresql-contrib \
	python-pip \
	libnuma-dev

RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN dpkg-reconfigure dash

RUN apt-get -yq install curl
RUN apt-get -yq install bsdmainutils 
RUN apt-get -yq install git software-properties-common python3
RUN apt-add-repository -y ppa:webupd8team/java
RUN apt-get -yq update
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen   true | debconf-set-selections
RUN apt-get -yq install oracle-java8-installer

RUN mkdir -p /usr/local/bin && \
	curl -fsSL git.io/getdeepdive > /usr/local/bin/getdeepdive.sh && \
	chmod 755 /usr/local/bin/getdeepdive.sh

ARG DD_PASSWORD
ENV DD_PASSWORD=${DD_PASSWORD:-changeme}

RUN sed -i -e '/^%sudo/s/ALL[ \t]*$/NOPASSWD: ALL/'  /etc/sudoers
RUN useradd -c "Deep Diver,,," -m -s /bin/bash --groups sudo deepdiver && \
	echo deepdiver:${DD_PASSWORD}  | chpasswd -c SHA512

USER deepdiver
WORKDIR /home/deepdiver
RUN echo PATH="/home/deepdiver/local/bin:$PATH" >> ~/.bashrc
RUN id 
RUN getdeepdive.sh postgres
RUN getdeepdive.sh deepdive_from_release
RUN getdeepdive.sh deepdive_examples_tests
RUN getdeepdive.sh spouse_example

ADD run-postgresql.sh /usr/bin
ADD supervisor-postgresql.conf /etc/supervisor/conf.d/

ENTRYPOINT [ "/usr/bin/supervisord" ]
