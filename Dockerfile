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
    && apt install -y --no-install-recommends software-properties-common gnupg2 icnsutils xz-utils zip bc wget curl imagemagick icoutils rsync sed coreutils jq grep \
    && mkdir -pm755 /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources \
    && apt update \
    && mkdir -p /tmp && cd /tmp/ \
    && apt install -y winehq-devel winbind cabextract xvfb \
    && chmod +x /opt/majorsilence/wine-bundler \
    && mkdir -p /${WINEPREFIX} \
    && apt-get clean \
    && rm -rf /tmp/* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN winecfg && wineboot -u \
    && wineserver -k

RUN wget --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:133.0) Gecko/20100101 Firefox/133.0" -O /opt/majorsilence/windowsdesktop-runtime-win-x64.exe https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/10.0.5/windowsdesktop-runtime-10.0.5-win-x64.exe \
    && filehash="cbb1ad53aecc54264488cc5c0be938991770750209cf4acd383bbe8af57db679f4d5988e6281a6d6a46b4e141db3d3d539ea764250b4ab48871972a610944b40" \
    && echo "${filehash}  /opt/majorsilence/windowsdesktop-runtime-win-x64.exe" | sha512sum -c - || exit 1 \
    && ls -la /opt/majorsilence \
    && xvfb-run wine /opt/majorsilence/windowsdesktop-runtime-win-x64.exe /quiet /install /norestart \& \
    && sleep 60 \
    && rm -rf /opt/majorsilence/windowsdesktop-runtime-win-x64.exe
    
