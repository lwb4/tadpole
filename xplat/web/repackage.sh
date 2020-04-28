#!/usr/bin/env bash
set -e

echo "Repackaging due to changes ..."
python ../../deps/emsdk/upstream/emscripten/tools/file_packager.py tadpole.data \
    --preload ../../assets/fonts ../../assets/images ../../assets/scripts ../../assets/sounds \
    2>&1 >/dev/null
