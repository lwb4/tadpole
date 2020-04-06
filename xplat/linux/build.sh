#!/usr/bin/env bash

set -e
set -x

CURRDIR="$(pwd)"
ROOTDIR="$CURRDIR/../.."
SRCDIR="$ROOTDIR/src"
BUILDDIR="$ROOTDIR/build/all-linux"
LUADIR="$LUADIR/deps/lua"

cc \
    "$SRCDIR/*.cpp" \
    $(find $LUADIR -name '*.c' | grep -v lua.c) \
    -I "$BUILDDIR/include" \
    -L "$BUILDDIR/lib" \
    -o tadpole


