#include <stdio.h>
#include <vector>

#include "global.h"
#include "network.h"
#include "gamelib.h"

#ifdef BUILD_TARGET_ANDROID
#include "android.h"
#endif

SDL_Window *WINDOW;
SDL_Renderer *RENDERER;

lua_State *LUA_STATE;

SDL_Rect SCREEN_RECT = { 0, 0, 640, 480 };
std::vector<gamelib_texture> *TEXTURES;
std::vector<TTF_Font*> *FONTS;
std::vector<Mix_Music*> *MUSIC;

void one_frame();
int error_in_sdl(const char *msg);

int error_in_lua(const char *msg);
int start_lua_game();
int do_lua_frame();

unsigned long register_texture(SDL_Texture *t);
SDL_Color string_to_color(const char *color);

int initialize_libraries();
void destroy_libraries();

void continue_main();
void on_network_request(RECV_MESSAGE_TYPE msg);

bool IS_RUNNING;

#undef main
int main(int argc, char* args[]) {

#ifdef BUILD_TARGET_ANDROID
    start_logger("android-rostrum");
#endif

    int err;
    
    if ((err = initialize_libraries()) != 0) {
        return err;
    }
    
    if ((err = initialize_gamelib()) != 0) {
        destroy_libraries();
        return err;
    }

    connect_socket(continue_main);

    return 0;
}

void continue_main() {
    if (start_lua_game() != 0) {
        destroy_libraries();
        return;
    }

    set_message_listener(on_network_request);
    
    start_network_enabled_game_loop(one_frame, 60);

    close_socket();
    destroy_libraries();
}

void one_frame() {
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
        if (event.type == SDL_QUIT) {
            IS_RUNNING = false;
        }
    }
    do_lua_frame();
}

int initialize_libraries() {
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) < 0) {
        return error_in_sdl("initialize");
    }
    
    int flags;
#if defined(BUILD_TARGET_IOS) || defined(BUILD_TARGET_ANDROID)
    SDL_DisplayMode current;
    if (SDL_GetCurrentDisplayMode(0, &current) != 0) {
        return error_in_sdl("display mode");
    }
    SCREEN_RECT.w = current.w;
    SCREEN_RECT.h = current.h;
    flags = SDL_WINDOW_SHOWN | SDL_WINDOW_FULLSCREEN;
#else
    flags = SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE;
#endif
    
    if (SDL_CreateWindowAndRenderer(SCREEN_RECT.w, SCREEN_RECT.h, flags, &WINDOW, &RENDERER) != 0) {
        return error_in_sdl("window or renderer");
    }
    if (TTF_Init() < 0) {
        return error_in_sdl("loading ttf");
    }
    FONTS = new std::vector<TTF_Font*>();
    
    MUSIC = new std::vector<Mix_Music*>();
    flags = MIX_INIT_OGG;
    int initted = Mix_Init(flags);
    if (initted != flags) {
        fprintf(stderr, "Mix_Init: %s\n", Mix_GetError());
        return 1;
    }
    if (Mix_OpenAudio(MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT, 2, 1024) < 0) {
        fprintf(stderr, "Mix_OpenAudio: %s\n", Mix_GetError());
        return 1;
    }
    
    return 0;
}

int error_in_sdl(const char *msg) {
    fprintf(stderr, "SDL_Error in %s: %s\n", msg, SDL_GetError());
    return 1;
}

void destroy_libraries() {
    for (auto font : *FONTS) {
        TTF_CloseFont(font);
    }
    delete FONTS;
    TTF_Quit();
    for (auto img : *TEXTURES) {
        SDL_DestroyTexture(img.texture);
    }
    delete TEXTURES;
    for (auto music : *MUSIC) {
        Mix_FreeMusic(music);
    }
    Mix_CloseAudio();
    Mix_Quit();
    SDL_DestroyRenderer(RENDERER);
    SDL_DestroyWindow(WINDOW);
    SDL_Quit();
}

int error_in_lua(const char *msg) {
    fprintf(stderr, "%s: %s\n", msg, lua_tostring(LUA_STATE, -1));
    return 1;
}

void on_network_request(RECV_MESSAGE_TYPE msg) {
    lua_getglobal(LUA_STATE, "on_network_request");
    lua_pushstring(LUA_STATE, (char*) msg);
    if (lua_pcall(LUA_STATE, 1, 0, 0) != 0) {
        error_in_lua("on_network_request");
    }
}

int start_lua_game() {
    SDL_RWops *io = SDL_RWFromFile("scripts/main.lua", "rb");
    if (io == NULL) {
        fprintf(stderr, "could not load sample lua script");
        return 1;
    }
    size_t size = io->size(io);
    char *buf = (char*) malloc(size);
    while (io->read(io, buf, size, 1) > 0);

    if (luaL_loadbuffer(LUA_STATE, buf, size, "sample") || lua_pcall(LUA_STATE, 0, 0, 0)) {
        return error_in_lua("load");
    }

    SDL_RWclose(io);
    delete buf;
    return 0;
}

int do_lua_frame() {
    lua_getglobal(LUA_STATE, "frame");
    if (lua_pcall(LUA_STATE, 0, 0, 0) != 0) {
        return error_in_lua("frame");
    }
    return 0;
}
