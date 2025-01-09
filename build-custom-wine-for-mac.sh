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
    brew install llvm lld
    brew install --cask gstreamer-development
    echo 'export PATH="/opt/homebrew/opt/bison/bin:$PATH"' >> ~/.zshrc
    echo 'export PATH="/opt/homebrew/opt/llvm/bin:$PATH"' >> ~/.zshrc
    echo 'export PATH="/opt/homebrew/Cellar/lld/19.1.6/bin:$PATH"' >> ~/.zshrc
    source ~/.zshrc    

    # install runtime dependencies
    brew install —-formula freetype gnutls molten-vk sdl2
}

build_wine_x86_64(){
    export CPPFLAGS="-I/opt/homebrew/include -I/opt/homebrew/Cellar/molten-vk/1.2.11/include"
    export LDFLAGS="-L/opt/homebrew/lib -L/opt/homebrew/Cellar/molten-vk/1.2.11/lib -L/opt/homebrew/opt/bison/lib"
    # /opt/homebrew/Cellar/vulkan-headers/1.4.304
    
    WINE_BRANCH=wine-9.21

    mkdir -p $CWD/build

    if [ ! -d "$CWD/build/wine-x86_64/.git" ]; then
        git clone https://gitlab.winehq.org/wine/wine.git $CWD/build/wine-x86_64
    fi
    cd $CWD/build/wine-x86_64
    git config --global --add safe.directory $CWD/build/wine-x86_64
    git fetch origin
     if [ "$(git rev-parse --abbrev-ref HEAD)" != "branch-$WINE_BRANCH" ]; then
        git checkout --no-track -b branch-$WINE_BRANCH $WINE_BRANCH --
    fi
    
    cd $CWD/build/wine-x86_64
     ./configure --host=x86_64-apple-darwin --enable-win64 --disable-option-checking \
    --disable-tests \
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
    --without-gstreamer \
    --without-inotify \
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
    --without-sdl \
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
    tar -czvf $CWD/build/wine-macos-x86_64.tar.gz .
}


build_wine_aarch64(){
    export CPPFLAGS="-I/opt/homebrew/include -I/opt/homebrew/Cellar/molten-vk/1.2.11/include"
    export LDFLAGS="-L/opt/homebrew/lib -L/opt/homebrew/Cellar/molten-vk/1.2.11/lib -L/opt/homebrew/opt/bison/lib"
    # /opt/homebrew/Cellar/vulkan-headers/1.4.304
    
    WINE_BRANCH=wine-9.21

    mkdir -p $CWD/build

    if [ ! -d "$CWD/build/wine-aarch64/.git" ]; then
        git clone https://gitlab.winehq.org/wine/wine.git $CWD/build/wine-aarch64
    fi
    cd $CWD/build/wine-aarch64
    git config --global --add safe.directory $CWD/build/wine-aarch64
    git fetch origin
    if [ "$(git rev-parse --abbrev-ref HEAD)" != "branch-$WINE_BRANCH" ]; then
        git checkout --no-track -b branch-$WINE_BRANCH $WINE_BRANCH --
    fi
    
   
    cd $CWD/build/wine-aarch64

    # Set up environment variables for cross-compilation
    # windows x64
    #export CC=x86_64-w64-mingw32-gcc
    #export CXX=x86_64-w64-mingw32-g++
    #export PATH=/usr/x86_64-w64-mingw32/bin:$PATH


    ./configure --host=aarch64-apple-darwin --enable-win64 --disable-option-checking \
    --disable-tests \
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
    --without-gstreamer \
    --without-inotify \
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
    --without-sdl \
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

    lipo -create -output $CWD/build/wine-output/wine64 $CWD/build/wine-x86_64/wine64 $CWD/build/wine-aarch/wine64
    mkdir -p $CWD/build/wine-universal
    lipo -info $CWD/build/wine-universal/wine64
}


function create_universal_package(){
    lipo -create -output $CWD/build/wine-output/wine64 $CWD/build/wine-x86_64/wine64 $CWD/build/wine-aarch/wine64
    mkdir -p $CWD/build/wine-universal
    lipo -info $CWD/build/wine-universal/wine64
}

#build_wine_x86_64
build_wine_aarch64
#create_universal_package