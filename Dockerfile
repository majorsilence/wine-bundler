FROM ubuntu:noble

ARG DEBIAN_FRONTEND=noninteractive

LABEL maintainer="Peter Gill <peter@majorsilence.com>"

WORKDIR /
COPY ./wine-bundler /opt/majorsilence/wine-bundler
COPY ./LICENSE /opt/majorsilence/LICENSE
COPY ./README.md /opt/majorsilence/README.md

ENV WINEPREFIX=/opt/majorsilence/wine64
ENV WINEARCH=win64

# Note: wine is installed to run the wine-bundler script to generate a wine prefix.  The actual mac app is built using a portable mac wine build.
RUN mkdir -p /opt/majorsilence && apt update \
    && dpkg --add-architecture i386 \
    && apt update \
    && apt install -y --no-install-recommends software-properties-common gnupg2 xz-utils zip bc wget curl imagemagick icoutils rsync sed coreutils jq grep \
    && mkdir -pm755 /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources \
    && apt update \
    && mkdir -p /tmp && cd /tmp/ \
    && apt install -y winehq-devel winbind cabextract xvfb \
    && chmod +x /opt/majorsilence/wine-bundler \
    && mkdir -p /${WINEPREFIX} \
    && wget --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:133.0) Gecko/20100101 Firefox/133.0" -O /opt/majorsilence/windowsdesktop-runtime-8-win-x64.exe https://download.visualstudio.microsoft.com/download/pr/27bcdd70-ce64-4049-ba24-2b14f9267729/d4a435e55182ce5424a7204c2cf2b3ea/windowsdesktop-runtime-8.0.11-win-x64.exe \
    && winecfg && wineboot -u \
    && ls -la /opt/majorsilence \
    && wine /opt/majorsilence/windowsdesktop-runtime-8-win-x64.exe /quiet /install \
    && wineserver -k \
    && rm -rf /opt/majorsilence/windowsdesktop-runtime-8-win-x64.exe \
    && rm -rf /tmp/* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
