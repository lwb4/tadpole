#!/usr/bin/env bash

set -e
set -x

CURRDIR="$(pwd)"
ROOTDIR="$CURRDIR/../.."
SRCDIR="$ROOTDIR/src"
BUILDDIR="$ROOTDIR/build/all-linux"
LUADIR="$ROOTDIR/deps/lua"

rm -rf lua || true
mkdir lua
cd lua
gcc \
    -c \
    $(find $LUADIR -maxdepth 1 -name '*.c' | grep -v lua.c)
ar rcs liblua.a *.o
cd ..

g++ \
    -g \
    $SRCDIR/*.cpp \
    -I"$BUILDDIR/include" \
    -I"$LUADIR" \
    -L"$BUILDDIR/lib" \
    -L"$CURRDIR/lua" \
    -DBUILD_TARGET_LINUX \
    -Wl,-Bstatic \
    -lSDL2 -lSDL2_ttf -lSDL2_image -lSDL2_mixer -lwebsockets -lmbedtls -lmbedcrypto -lmbedx509 -llua \
    -Wl,-Bdynamic \
    -lfreetype -ldl -pthread \
    -o tadpole


cp -R $ROOTDIR/assets/* .
