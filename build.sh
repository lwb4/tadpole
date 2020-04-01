#!/usr/bin/env bash

set -e

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

buildNative() {
    echo "building for $1"
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
BASENAME=`basename $(pwd)`

if [ -z "$IS_GIT_REPO" ] || [ "$BASENAME" != "tadpole" ]; then
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
    MINGW*)     Machine=MinGW;;
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
