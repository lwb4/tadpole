#!/usr/bin/env bash

CMAKE_NAME="cmake-3.17.0-Linux-x86_64"
SOURCE_URL="https://github.com/Kitware/CMake/releases/download/v3.17.0/$CMAKE_NAME.sh"
wget $SOURCE_URL
yes | sudo bash $CMAKE_NAME.sh
export PATH="$(pwd)/$CMAKE_NAME/bin:$PATH"
