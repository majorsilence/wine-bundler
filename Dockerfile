FROM ubuntu:noble

ARG DEBIAN_FRONTEND=noninteractive

LABEL maintainer="Peter Gill <peter@majorsilence.com>"

WORKDIR /
COPY ./wine-bundler /wine-bundler
COPY ./LICENSE /LICENSE
COPY ./README.md /README.md

RUN apt update \
    && apt install -y --no-install-recommends wget curl imagemagick icoutils rsync sed coreutils jq grep \
    && chmod +x /wine-bundler \
    && rm -rf /tmp/* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
