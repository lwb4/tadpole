#!/usr/bin/env bash
set -e

if [ -z $(type -t $function) ]; then
    source ../../deps/emsdk/emsdk_env.sh
fi

build() {
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
        -s FORCE_FILESYSTEM=1 \
        -o tadpole.html \
        --preload-file ../../assets/fonts@/fonts \
        --preload-file ../../assets/images@/images \
        --preload-file ../../assets/scripts@/scripts \
        --preload-file ../../assets/sounds@/sounds
    echo "BUILD SUCCEEDED!"
}

runserver() {
    if [[ $(lsof -t -i tcp:5000) ]]; then
        echo 'Killing running server ...'
        lsof -t -i tcp:5000 | xargs kill
    fi

    echo ""
    echo "VISIT THIS PAGE IN YOUR BROWSER:"
    echo "http://localhost:5000/tadpole.html"
    echo ""
    echo "Running server..."
    python -m SimpleHTTPServer 5000
}

# This currently doesn't work.
# emscripten outputs a js file as part of this (to stdout) that is supposed to be loaded before our .data file
# this _could_ work if we could rip out the old js file from the html file and add the new one, but I'm too lazy to implement that for now
# Probably the real solution is to make our own html file instead of using the one generated by emscripten
watch() {
    build
    runserver &
    sleep 1
    echo
    echo "Watching for filesystem changes ..."
    fswatch -t0 ../../assets/ | xargs -0 -n 1 ./repackage.sh
}

if [[ $1 == "noserver" ]]; then
    build
else
    watch
fi

exit 0
