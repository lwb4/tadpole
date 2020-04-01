#include <stdio.h>
#include <vector>
#include <string.h>

#include <errno.h>
#include "global.h"
#include "gamelib.h"
#include "network.h"

extern SDL_Renderer *RENDERER;
extern lua_State *LUA_STATE;
extern std::vector<gamelib_texture> *TEXTURES;
extern SDL_Rect SCREEN_RECT;
extern std::vector<TTF_Font*> *FONTS;
extern std::vector<Mix_Music*> *MUSIC;

void register_lib_function(const char *name, lua_CFunction func) {
    lua_pushstring(LUA_STATE, name);
    lua_pushcfunction(LUA_STATE, func);
    lua_settable(LUA_STATE, -3);
}

SDL_Color string_to_color(const char *color) {
    if (strcasecmp(color, "black")) {
        return { 0, 0, 0, 255 };
    } else {
        return { 255, 255, 255, 255 };
    }
}

unsigned long register_texture(SDL_Texture *t) {
    int w, h;
    SDL_QueryTexture(t, NULL, NULL, &w, &h);
    SDL_Rect rect = {0, 0, w, h};
    gamelib_texture texture;
    texture.texture = t;
    texture.rect = rect;
    TEXTURES->push_back(texture);
    return TEXTURES->size() - 1;
}

int gamelib_fill_screen_with_color(lua_State *L) {
    int r = luaL_checknumber(L, 1);
    int g = luaL_checknumber(L, 2);
    int b = luaL_checknumber(L, 3);
    SDL_SetRenderDrawColor(RENDERER, r, g, b, 255);
    SDL_RenderFillRect(RENDERER, &SCREEN_RECT);
    return 0;
}

int gamelib_load_image(lua_State *L) {
    const char *filename = lua_tostring(L, 1);
    SDL_Texture *texture = IMG_LoadTexture(RENDERER, filename);
    if (!texture) {
        luaL_error(L, "could not load image %s: %s", filename, SDL_GetError());
    }
    lua_pushnumber(L, register_texture(texture));
    return 1;
}

int gamelib_draw_texture(lua_State *L) {
    int x = luaL_checknumber(L, 1);
    int y = luaL_checknumber(L, 2);
    int index = luaL_checknumber(L, 3);
    if (index < 0 || index >= TEXTURES->size()) {
        luaL_error(L, "image index %d out of bounds", index);
    }
    SDL_Rect *rect = &TEXTURES->at(index).rect;
    rect->x = x;
    rect->y = y;
    if (SDL_RenderCopy(RENDERER, TEXTURES->at(index).texture, NULL, rect)) {
        luaL_error(L, "could not render texture: %s", SDL_GetError());
    }
    return 0;
}

int gamelib_render(lua_State *L) {
    SDL_RenderPresent(RENDERER);
    return 0;
}

int gamelib_get_platform(lua_State *L) {
#ifdef BUILD_TARGET_MACOS
    lua_pushstring(L, "mac");
#endif
#ifdef BUILD_TARGET_WINDOWS
    lua_pushstring(L, "windows");
#endif
#ifdef BUILD_TARGET_LINUX
    lua_pushstring(L, "linux");
#endif
#ifdef BUILD_TARGET_BROWSER
    lua_pushstring(L, "browser");
#endif
#ifdef BUILD_TARGET_IOS
    lua_pushstring(L, "ios");
#endif
#ifdef BUILD_TARGET_ANDROID
    lua_pushstring(L, "android");
#endif
    return 1;
}

int gamelib_has_keyboard(lua_State *L) {
#ifdef BUILD_TARGET_MACOS
    lua_pushboolean(L, true);
#endif
#ifdef BUILD_TARGET_WINDOWS
    lua_pushboolean(L, true);
#endif
#ifdef BUILD_TARGET_LINUX
    lua_pushboolean(L, true);
#endif
#ifdef BUILD_TARGET_BROWSER
    lua_pushboolean(L, true);
#endif
#ifdef BUILD_TARGET_IOS
    lua_pushboolean(L, false);
#endif
#ifdef BUILD_TARGET_ANDROID
    lua_pushboolean(L, false);
#endif
    return 1;
}

int gamelib_is_key_pressed(lua_State *L) {
    const char *keyname = lua_tostring(L, 1);
    const Uint8 *state = SDL_GetKeyboardState(NULL);
    SDL_Scancode scancode = SDL_GetScancodeFromName(keyname);
    if (scancode == SDL_SCANCODE_UNKNOWN) {
        luaL_error(L, "key name %s unknown", keyname);
    }
    lua_pushboolean(L, state[scancode]);
    return 1;
}

int gamelib_get_touch_coordinates(lua_State *L) {
    int x, y;
    if (SDL_GetMouseState(&x, &y) & SDL_BUTTON(SDL_BUTTON_LEFT)) {
        lua_pushnumber(L, x);
        lua_pushnumber(L, y);
        return 2;
    }
    lua_pushnil(L);
    lua_pushnil(L);
    return 2;
}

int gamelib_debug(lua_State *L) {
    const char *msg = lua_tostring(L, 1);
    printf("lua debug: %s\n", msg);
    return 0;
}

int gamelib_load_font(lua_State *L) {
    const char *filename = lua_tostring(L, 1);
    int ptsize = luaL_checknumber(L, 2);
    TTF_Font *font = TTF_OpenFont(filename, ptsize);
    FONTS->push_back(font);
    lua_pushnumber(L, FONTS->size() - 1);
    return 1;
}

int gamelib_load_text(lua_State *L) {
    int index = luaL_checknumber(L, 1);
    if (index < 0 || index >= FONTS->size()) {
        luaL_error(L, "font index %d out of bounds", index);
    }
    
    const char *msg = lua_tostring(L, 2);
    
    SDL_Color color;
    const char *str_color = lua_tostring(L, 3);
    if (str_color) {
        color = string_to_color(str_color);
    } else if (lua_istable(L, 3)) {
        lua_getfield(L, 3, "r");
        lua_getfield(L, 3, "g");
        lua_getfield(L, 3, "b");
        color.r = luaL_checknumber(L, -3);
        color.g = luaL_checknumber(L, -2);
        color.b = luaL_checknumber(L, -1);
    } else {
        luaL_error(L, "color argument not supplied");
    }
    SDL_Surface *surface = TTF_RenderText_Blended_Wrapped(FONTS->at(index), msg, color, SCREEN_RECT.w);
    SDL_Texture *text_obj = SDL_CreateTextureFromSurface(RENDERER, surface);
    SDL_FreeSurface(surface);
    lua_pushnumber(L, register_texture(text_obj));
    return 1;
}

int gamelib_load_music(lua_State *L) {
    const char *filename = lua_tostring(L, 1);
    Mix_Music *music = Mix_LoadMUS(filename);
    if (!music) {
        luaL_error(L, "could not load music file %s", filename);
    }
    MUSIC->push_back(music);
    lua_pushnumber(L, MUSIC->size() - 1);
    return 1;
}

int gamelib_play_music(lua_State *L) {
    int index = luaL_checknumber(L, 1);
    int loops = luaL_checknumber(L, 2);
    if (index < 0 || index >= MUSIC->size()) {
        luaL_error(L, "music index %d out of bounds", index);
    }
    if (Mix_PlayMusic(MUSIC->at(index), loops) < 0) {
        luaL_error(L, "error playing music: %s", Mix_GetError());
    }
    return 0;
}

int gamelib_send_network_request(lua_State *L) {
    SEND_MESSAGE_TYPE msg = lua_tostring(L, 1);
    send_message_on_socket(msg);
    return 0;
}

int gamelib_get_screen_dimensions(lua_State *L) {
    lua_pushnumber(L, SCREEN_RECT.w);
    lua_pushnumber(L, SCREEN_RECT.h);
    return 2;
}

int initialize_gamelib() {
    LUA_STATE = luaL_newstate();
    if (!LUA_STATE) {
        fprintf(stderr, "luaL_newstate failed");
        return 1;
    }

    luaL_openlibs(LUA_STATE);

    // set up the lib table
    lua_newtable(LUA_STATE);
    
    register_lib_function("fill_screen_with_color", gamelib_fill_screen_with_color);
    register_lib_function("load_image", gamelib_load_image);
    register_lib_function("draw_texture", gamelib_draw_texture);
    register_lib_function("render", gamelib_render);
    register_lib_function("get_platform", gamelib_get_platform);
    register_lib_function("has_keyboard", gamelib_has_keyboard);
    register_lib_function("is_key_pressed", gamelib_is_key_pressed);
    register_lib_function("get_touch_coordinates", gamelib_get_touch_coordinates);
    register_lib_function("debug", gamelib_debug);
    register_lib_function("load_font", gamelib_load_font);
    register_lib_function("load_text", gamelib_load_text);
    register_lib_function("load_music", gamelib_load_music);
    register_lib_function("play_music", gamelib_play_music);
    register_lib_function("send_network_request", gamelib_send_network_request);
    register_lib_function("get_screen_dimensions", gamelib_get_screen_dimensions);

    lua_setglobal(LUA_STATE, "lib");
    
    // set up the image list
    TEXTURES = new std::vector<gamelib_texture>();

    return 0;
}

void destroy_gamelib() {
    lua_close(LUA_STATE);
}
