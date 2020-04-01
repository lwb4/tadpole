#!/usr/bin/env bash
set -e
emcc ../../src/client/*.cpp \
    $(ls ../../deps/lua/src/*.c | grep -v -e 'lua[\.c]') \
    -D BUILD_TARGET_BROWSER \
    -I ../../src/client \
    -I ../../deps/lua/src \
    -lwebsocket.js \
    -lopenal \
    -s USE_SDL=2 \
    -s USE_SDL_TTF=2 \
    -s USE_SDL_IMAGE=2 \
    -s SDL2_IMAGE_FORMATS='["bmp","png"]' \
    -s USE_SDL_MIXER=2 \
    -o dist/rostrum.html \
    --preload-file ../../assets/fonts@/fonts \
    --preload-file ../../assets/img@/img \
    --preload-file ../../assets/scripts@/scripts \
    --preload-file ../../assets/sounds@/sounds
echo "BUILD SUCCEEDED!"
echo ""
echo "VISIT THIS PAGE IN YOUR BROWSER:"
echo "http://localhost:5000/dist/rostrum.html"
echo ""
echo "Running server..."
python -m SimpleHTTPServer 5000
