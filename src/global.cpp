#include "global.h"

extern lua_State *LUA_STATE;

int error_in_lua(const char *msg) {
    fprintf(stderr, "%s: %s\n", msg, lua_tostring(LUA_STATE, -1));
    return 1;
}
