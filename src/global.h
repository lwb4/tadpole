#ifndef include_sdl_hpp
#define include_sdl_hpp

#if defined(BUILD_TARGET_MACOS) || defined(BUILD_TARGET_LINUX)
#include <SDL2/SDL.h>
#else
#include "SDL.h"
#endif
#include "SDL_image.h"
#include "SDL_ttf.h"
#include "SDL_mixer.h"

#ifdef BUILD_TARGET_BROWSER
#include <emscripten.h>
#endif

#include "lua.hpp"
#include "lauxlib.h"
#include "lualib.h"

#ifndef BUILD_TARGET_WINDOWS
#include <unistd.h>
#include <strings.h>
#endif

struct gamelib_texture {
    SDL_Texture *texture;
    SDL_Rect rect;
};

#endif
