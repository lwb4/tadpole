#!/usr/bin/env bash

CMAKE_NAME="cmake-3.17.0-Linux-x86_64"
SOURCE_URL="https://github.com/Kitware/CMake/releases/download/v3.17.0/$CMAKE_NAME.tar.gz"
wget $SOURCE_URL
tar xvf $CMAKE_NAME.tar.gz
export PATH="$(pwd)/$CMAKE_NAME/bin:$PATH"
