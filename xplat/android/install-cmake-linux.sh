#!/usr/bin/env bash

CMAKE_NAME="cmake-3.17.0-Linux-x86_64"
SOURCE_URL="https://github.com/Kitware/CMake/releases/download/v3.17.0/$CMAKE_NAME.tar.gz"
CMAKE_PATH="$(which cmake)"
wget $SOURCE_URL
tar xf $CMAKE_NAME.tar.gz
sudo rm "$CMAKE_PATH"
sudo ln -s "$(pwd)/$CMAKE_NAME/bin/cmake" "$CMAKE_PATH"
