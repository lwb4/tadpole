#!/usr/bin/env bash
set -e

echo "Repackaging due to changes ..."
python ../../deps/emsdk/upstream/emscripten/tools/file_packager.py tadpole.data \
    --preload ../../assets/fonts ../../assets/images ../../assets/scripts ../../assets/sounds \
    >/dev/null 2>&1