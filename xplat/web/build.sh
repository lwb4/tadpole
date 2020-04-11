#!/usr/bin/env bash
set -e

if [ -z $(type -t $function) ]; then
    source ../../deps/emsdk/emsdk_env.sh
fi

echo "Building ..."

emcc ../../src/*.cpp \
    $(ls ../../deps/lua/*.c | grep -v 'lua.c') \
    -D BUILD_TARGET_BROWSER \
    -I ../../src \
    -I ../../deps/lua \
    -lwebsocket.js \
    -lopenal \
    -s USE_SDL=2 \
    -s USE_SDL_TTF=2 \
    -s USE_SDL_IMAGE=2 \
    -s SDL2_IMAGE_FORMATS='["bmp","png"]' \
    -s USE_SDL_MIXER=2 \
    -o tadpole.html \
    --preload-file ../../assets/fonts@/fonts \
    --preload-file ../../assets/images@/images \
    --preload-file ../../assets/scripts@/scripts \
    --preload-file ../../assets/sounds@/sounds
echo "BUILD SUCCEEDED!"

runserver() {
    echo ""
    echo "VISIT THIS PAGE IN YOUR BROWSER:"
    echo "http://localhost:5000/tadpole.html"
    echo ""
    echo "Running server..."
    python -m SimpleHTTPServer 5000
}

[[ -z "$1" ]] && runserver
exit 0
