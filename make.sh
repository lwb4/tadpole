#!/usr/bin/env bash

set -e

CURRDIR="$(pwd)"
LINUX_INSTALL="$CURRDIR/build/all-linux"
MACOS_INSTALL="$CURRDIR/build/lws-macos"
ANDROID_JNI_DIR="$CURRDIR/xplat/android/app/jni"
ANDROID_WORKING_DIR="$CURRDIR/xplat/android/app/src/main"
ANDROID_INSTALL="$CURRDIR/build/lws-android"

: "${NDK_ROOT?Environment variable NDK_ROOT not set}"

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
    echo "    browser   -- install and activate the Emscripten SDK"
    echo ""
    echo "this only builds libraries; to run your program, you still have to"
    echo "build each platform individually in their respective xplat folders"
    echo ""
    echo "this script MUST be called from the top level directory"
    echo ""
}

buildLinux() {
    export CPPFLAGS="-I$LINUX_INSTALL/include -fPIC"
    export LDFLAGS="-I$LINUX_INSTALL/lib"

    echo "<=================== sdl"
    cd "$CURRDIR/deps/SDL"
    ./configure --prefix "$LINUX_INSTALL"
    make
    make install

    echo "<=================== sdl_image"
    cd "$CURRDIR/deps/SDL_image"
    sh autogen.sh
    ./configure --prefix "$LINUX_INSTALL"
    make
    make install

    echo "<=================== sdl_mixer"
    cd "$CURRDIR/deps/SDL_mixer"
    sh autogen.sh
    ./configure --prefix "$LINUX_INSTALL"
    make
    make install

    echo "<=================== sdl_ttf"
    cd "$CURRDIR/deps/SDL_ttf"
    sh autogen.sh
    ./configure --prefix "$LINUX_INSTALL"
    make
    make install

    echo "<=================== mbedtls"
    cd "$CURRDIR/deps/mbedtls"
    make clean
    make no_test CC="cc -fPIC"
    make install DESTDIR="$LINUX_INSTALL"

    echo "<=================== libwebsockets"
    cd "$LINUX_INSTALL"
    cmake \
        -DLWS_WITH_MBEDTLS=ON \
        -DLWS_MBEDTLS_LIBRARIES="$LINUX_INSTALL/lib/libmbedtls.a;$LINUX_INSTALL/lib/libmbedcrypto.a;$LINUX_INSTALL/lib/libmbedx509.a" \
        -DLWS_MBEDTLS_INCLUDE_DIRS="$LINUX_INSTALL/include" \
        "$CURRDIR/deps/libwebsockets"
    make
    sudo make install

    echo ""
    echo "now go into the xplat/linux directory and run ./build.sh to run your program!"
    echo ""
}

buildMac() {
    echo "<=================== mbedtls"
    cd "$CURRDIR/deps/mbedtls"
    make no_test CC="cc -fPIC"
    make install DESTDIR="$MACOS_INSTALL"

    echo "<=================== libwebsockets"
    cd "$MACOS_INSTALL"
    cmake \
        -DLWS_WITH_MBEDTLS=ON \
        -DLWS_MBEDTLS_LIBRARIES="$MACOS_INSTALL/lib/libmbedtls.a;$MACOS_INSTALL/lib/libmbedcrypto.a;$MACOS_INSTALL/lib/libmbedx509.a" \
        -DLWS_MBEDTLS_INCLUDE_DIRS="$MACOS_INSTALL/include" \
        "$CURRDIR/deps/libwebsockets"
    make
    sudo make install

    echo ""
    echo "now open up the project file xplat/macos/tadpole.xcodeproj in Xcode to run your program!"
    echo ""
}

buildNative() {
    case "$1" in
        Linux)  buildLinux;;
        Mac)    buildMac;;
        *)      ;;
    esac
}

make_lws_android() {
    PREFIX="$ANDROID_INSTALL/$1"

    set +e
    rm -rf \
        $PREFIX \
        "$CURRDIR/deps/libwebsockets/CMakeCache.txt" \
        "$CURRDIR/deps/mbedtls/CMakeCache.txt" \
        2>/dev/null
    set -e

    mkdir -p $PREFIX/{lws,mbed}
    cd $PREFIX

    cd $PREFIX/mbed
    cmake \
        -DCMAKE_INSTALL_PREFIX="$PREFIX/mbed" \
        -DENABLE_TESTING=OFF \
        -DENABLE_PROGRAMS=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DANDROID_NDK="$NDK_ROOT" \
        -DANDROID_ABI="$1" \
        -DCMAKE_TOOLCHAIN_FILE="$NDK_ROOT/build/cmake/android.toolchain.cmake" \
        "$CURRDIR/deps/mbedtls"
    make
    make install

    cd $PREFIX/lws
    cmake \
        -DCMAKE_INSTALL_PREFIX="$PREFIX/lws" \
        -DLWS_WITH_MBEDTLS=ON \
        -DLWS_MBEDTLS_LIBRARIES="$PREFIX/mbed/library/libmbedtls.a;$PREFIX/mbed/library/libmbedcrypto.a;$PREFIX/mbed/library/libmbedx509.a" \
        -DLWS_MBEDTLS_INCLUDE_DIRS="$PREFIX/mbed/include" \
        -DCMAKE_BUILD_TYPE=Release \
        -DANDROID_NDK="$NDK_ROOT" \
        -DANDROID_ABI="$1" \
        -DCMAKE_TOOLCHAIN_FILE="$NDK_ROOT/build/cmake/android.toolchain.cmake" \
        "$CURRDIR/deps/libwebsockets"
    make
    make install
}

buildAndroid() {
    set +e
    for val in SDL SDL_image SDL_mixer SDL_ttf lua; do
        rm "$ANDROID_JNI_DIR/$val" 2>/dev/null
        ln -s "$CURRDIR/deps/$val" "$ANDROID_JNI_DIR/$val"
    done

    for dir in fonts images scripts sounds; do
        rm "$ANDROID_WORKING_DIR/$dir" 2>/dev/null
        ln -s "$CURRDIR/assets/$dir" "$ANDROID_WORKING_DIR/assets/$dir"
    done

    rm "$ANDROID_WORKING_DIR/pollywog.games.cer" 2>/dev/null
    ln -s "$CURRDIR/xplat/pollywog.games.cer" "$ANDROID_WORKING_DIR/assets/pollywog.games.cer"
    set -e

    make_lws_android "armeabi-v7a"
    make_lws_android "arm64-v8a"
    make_lws_android "x86"
    make_lws_android "x86_64"
}

buildiOS() {
    echo "building for iOS"
}

buildBrowser() {
    cd deps/emsdk
    ./emsdk install latest
    ./emsdk activate latest
    source emsdk_env.sh

    echo ""
    echo "now go to xplat/web and run ./build.sh to run your program!"
    echo ""
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
    browser)    buildBrowser;;
    *)          printUsage;;
esac

cd "$CURRDIR"
