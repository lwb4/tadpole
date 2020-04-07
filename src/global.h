#ifndef include_sdl_hpp
#define include_sdl_hpp

#if defined(BUILD_TARGET_LINUX)
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>
#include <SDL2/SDL_mixer.h>
#else
#include "SDL.h"
#include "SDL_image.h"
#include "SDL_ttf.h"
#include "SDL_mixer.h"
#endif

#ifdef BUILD_TARGET_BROWSER
#include <emscripten.h>
#endif

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}

#ifndef BUILD_TARGET_WINDOWS
#include <unistd.h>
#include <strings.h>
#else
#include <string.h>
#endif

struct gamelib_texture {
    SDL_Texture *texture;
    SDL_Rect rect;
};

#endif
