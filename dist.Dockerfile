FROM debian:jessie
MAINTAINER chroma <leif@chroma.io>

RUN apt-get update \
&&  apt-get install -y libbz2-dev libsnappy-dev zlib1g-dev libzlcore-dev

ADD lib /usr/lib
ADD bin /usr/bin
