#!/usr/bin/env bash

set -e

CURRDIR="$(pwd)"
LINUX_INSTALL="$CURRDIR/build/all-linux"

######################
# DEFINE SUBCOMMANDS #
######################

printUsage() {
    echo ""
    echo "TADPOLE ENGINE BUILD SCRIPT"
    echo ""
    echo "convenience script for building dependencies from source"
    echo "all dependencies are built as static libraries"
    echo ""
    echo "usage: ./build.sh <command> where command is one of:"
    echo ""
    echo "    native    -- build for your computer's native architecture"
    echo "                  for example, on a Mac, this builds libraries for Mac"
    echo "    ios       -- cross-compile iOS libraries (only works on a Mac)"
    echo "    android   -- cross-compile Android libraries (works on all platforms)"
    echo ""
    echo "this only builds libraries; to run your program, you still have to"
    echo "build each platform individually in their respective xplat folders"
    echo ""
    echo "this script MUST be called from the top level directory"
    echo ""
}

buildLinux() {
    echo "<=================== sdl"
    cd "$CURRDIR/deps/SDL"
    ./configure --prefix "$LINUX_INSTALL"
    make
    make install

    echo "<=================== sdl_image"
    cd "$CURRDIR/deps/SDL_image"
    ./configure --prefix "$LINUX_INSTALL"
    make
    make install

    echo "<=================== sdl_mixer"
    cd "$CURRDIR/deps/SDL_mixer"
    ./configure --prefix "$LINUX_INSTALL"
    make
    make install

    echo "<=================== sdl_ttf"
    cd "$CURRDIR/deps/SDL_ttf"
    ./configure --prefix "$LINUX_INSTALL"
    make
    make install

    echo "<=================== mbedtls"
    cd "$CURRDIR/deps/mbedtls"
    make no_test
    make install DESTDIR="$LINUX_INSTALL"

    echo "<=================== libwebsockets"
    cd "$CURRDIR/build/all-linux"
    cmake \
        -DLWS_WITH_MBEDTLS=ON \
        -DLWS_MBEDTLS_LIBRARIES="$LINUX_INSTALL/lib/libmbedtls.a;$LINUX_INSTALL/lib/libmbedcrypto.a;$LINUX_INSTALL/lib/libmbedx509.a" \
        -DLWS_MBEDTLS_INCLUDE_DIRS="$LINUX_INSTALL/include" \
        "$CURRDIR/deps/libwebsockets"
    make
    make install

    echo ""
    echo "now go into the xplat/linux directory and run ./build.sh to run your program!"
    echo ""
}

buildMac() {
    echo "mac"
}

buildNative() {
    case "$1" in
        Linux)  buildLinux;;
        Mac)    buildMac;;
        *)      ;;
    esac
}

buildAndroid() {
    echo "building for android"
}

buildiOS() {
    echo "building for iOS"
}

########################
# DETECT CALL LOCATION #
########################

set +e
IS_GIT_REPO="$(ls .git 2> /dev/null)" 
set -e

if [ -z "$IS_GIT_REPO" ]; then
    echo "this script MUST be called from tadpole's top level directory"
    echo "please change your working directory to the root of the repository"
    echo "and run the script again."
    exit 1
fi

###########################
# DETECT OPERATING SYSTEM #
###########################

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="";;
esac

if [ -z "$MACHINE" ]; then
    echo "Your operating system ($unameOut) is not supported.";
    exit 1;
fi

####################
# CALL SUBCOMMANDS #
####################

case "$1" in
    native)     buildNative "$MACHINE";;
    android)    buildAndroid;;
    ios)        buildiOS;;
    *)          printUsage;;
esac

cd "$CURRDIR"
