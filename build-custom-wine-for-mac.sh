#!/usr/bin/env bash
set -e # exit on first error
set -u # exit on using unset variable

# a build script for running in the wine-macos64-builder-container
CWD=`pwd`

install_deps(){
    # https://gitlab.winehq.org/wine/wine/-/wikis/MacOS-Buildings

    # install build dependencies
    xcode-select --install
    brew install --formula bison mingw-w64 pkgconfig

    # install runtime dependencies
    brew install —-formula freetype gnutls molten-vk sdl2
}

build_wine(){

    WINE_BRANCH=wine-9.21

    mkdir -p $CWD/build

    if [ ! -d "$CWD/build/wine-tools/.git" ]; then
        git clone https://gitlab.winehq.org/wine/wine.git $CWD/build/wine-tools
    fi
    cd $CWD/build/wine-tools
    git config --global --add safe.directory $CWD/build/wine-tools
    git fetch origin
     if [ "$(git rev-parse --abbrev-ref HEAD)" != "branch-$WINE_BRANCH" ]; then
        git checkout --no-track -b branch-$WINE_BRANCH $WINE_BRANCH --
    fi
    
    
    if [ ! -d "$CWD/build/wine/.git" ]; then
        git clone https://gitlab.winehq.org/wine/wine.git $CWD/build/wine
    fi
    cd $CWD/build/wine
    git config --global --add safe.directory $CWD/build/wine
    git fetch origin
    if [ "$(git rev-parse --abbrev-ref HEAD)" != "branch-$WINE_BRANCH" ]; then
        git checkout --no-track -b branch-$WINE_BRANCH $WINE_BRANCH --
    fi
    

    cd $CWD/build/wine-tools 
    #./configure --without-x 
    #make __tooldeps__

    cd $CWD/build/wine

    # Set up environment variables for cross-compilation
    # windows x64
    #export CC=x86_64-w64-mingw32-gcc
    #export CXX=x86_64-w64-mingw32-g++
    #export PATH=/usr/x86_64-w64-mingw32/bin:$PATH

    
    export WINE_TOOLS="$CWD/build/wine-tools"

    #./configure --host=x86_64-apple-darwin --with-wine-tools=$WINE_TOOLS --enable-win64 \
    ./configure --disable-option-checking \
    --disable-tests \
    --enable-archs=i386,x86_64 \
    --without-alsa \
    --without-capi \
    --with-coreaudio \
    --with-cups \
    --without-dbus \
    --without-fontconfig \
    --with-freetype \
    --with-gettext \
    --without-gettextpo \
    --without-gphoto \
    --with-gnutls \
    --without-gssapi \
    --with-gstreamer \
    --with-inotify \
    --without-krb5 \
    --with-mingw \
    --without-netapi \
    --with-opencl \
    --with-opengl \
    --without-oss \
    --with-pcap \
    --with-pcsclite \
    --with-pthread \
    --without-pulse \
    --without-sane \
    --with-sdl \
    --without-udev \
    --with-unwind \
    --without-usb \
    --without-v4l2 \
    --with-vulkan \
    --without-wayland \
    --without-x

    # build wine
    make -j$(nproc)

    make install DESTDIR=$CWD/build/wine-build
    cd $CWD/build/wine-build
    tar -czvf $CWD/build/wine-macos64.tar.gz .

}

build_wine
