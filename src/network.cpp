#include "global.h"
#include "network.h"
#include <stdio.h>
#include <stdlib.h>
#include <vector>

#ifdef BUILD_TARGET_ANDROID
#include <pthread.h>
#endif

extern bool IS_RUNNING;

const char *SERVER_ADDRESS, *SERVER_PATH;
int SERVER_PORT;
bool SERVER_SECURE;

#ifdef BUILD_TARGET_BROWSER

// Emscripten has native support for websockets, so we use their API here
// In fact, any network request gets automatically converted into a websocket
// by the Emscripten runtime. The way they convert packets is confusing and
// opaque -- what better way to stay ahead of the curve than to opt out?

#include <emscripten.h>
#include <emscripten/websocket.h>

EMSCRIPTEN_WEBSOCKET_T ws;
void (*ONOPEN_FUNCTION)() = NULL;
void (*ONMESSAGE_FUNCTION)(RECV_MESSAGE_TYPE) = NULL;
void (*FRAME_FUNCTION)() = NULL;
SEND_MESSAGE_TYPE QUEUED_MESSAGE = NULL;

int onmessage(int eventType, const EmscriptenWebSocketMessageEvent *websocketEvent, void *userData) {
    if (ONMESSAGE_FUNCTION) {
      ONMESSAGE_FUNCTION(websocketEvent->data);
    }
    return 0;
}

int onopen(int eventType, const EmscriptenWebSocketOpenEvent *websocketEvent, void *userData) {
    emscripten_websocket_set_onmessage_callback(ws, NULL, onmessage);
    if (ONOPEN_FUNCTION) {
      ONOPEN_FUNCTION();
    }
    return 0;
}

void send_message_on_socket(SEND_MESSAGE_TYPE msg) {
    unsigned short ready_state;
    emscripten_websocket_get_ready_state(ws, &ready_state);
    if (ready_state == 0) {
        QUEUED_MESSAGE = msg;
    } else if (ready_state == 1) {
        emscripten_websocket_send_utf8_text(ws, msg);
        QUEUED_MESSAGE = NULL;
    } else {
        fprintf(stderr, "trying to send msg (%s) on a closed socket (ready state: %d)", msg, ready_state);
    }
}

void set_message_listener(void (*f)(RECV_MESSAGE_TYPE)) {
    ONMESSAGE_FUNCTION = f;
}

void close_socket() {
    emscripten_websocket_close(ws, 1000, "done");
    emscripten_websocket_delete(ws);
}

void connect_socket(
        const char* host,
        const char* path,
        int port,
        bool secure,
        void (*on_open)())
{
    struct EmscriptenWebSocketCreateAttributes attr;
    const char* protocol = secure ? "wss" : "ws";
    char url[256];
    snprintf(url, 256, "%s://%s:%d%s", protocol, host, port, path);
    attr.url = url;
    attr.protocols = NULL;
    attr.createOnMainThread = 1;
    ws = emscripten_websocket_new(&attr);
    if (ws < 0) {
        fprintf(stderr, "could not create websocket\n");
    }
    ONOPEN_FUNCTION = on_open;
    emscripten_websocket_set_onopen_callback(ws, NULL, onopen);
}

void create_network_context() {
    // nothing to be done
}

void emscripten_one_frame() {
    if (FRAME_FUNCTION) {
        FRAME_FUNCTION();
    }
    if (QUEUED_MESSAGE) {
        send_message_on_socket(QUEUED_MESSAGE);
    }
}

void start_network_enabled_game_loop(void (*f)(), int target_fps) {
    // A basic main loop to prevent blocking
    // Emscripten can't handle loops. See https://emscripten.org/docs/porting/emscripten-runtime-environment.html#browser-main-loop
    FRAME_FUNCTION = f;
    emscripten_set_main_loop(emscripten_one_frame, target_fps, 1);
}

#else

#ifdef BUILD_TARGET_WINDOWS
#include <iostream>
#endif

extern "C" {
#include <libwebsockets.h>
}

// all other platforms use libwebsockets (LWS)
// it is a little bit tricky to come up with a unified internal API for
// accessing websockets through both Emscripten Websockets and LWS,
// hence some quirkiness in these function signatures.

lws_sorted_usec_list_t  SUL;

static struct lws_context *LWS_CONTEXT;

static int service_callback(struct lws *wsi, enum lws_callback_reasons reason, void *user, void *in, size_t len);
static void one_frame(lws_sorted_usec_list_t *sul);
void schedule_next_frame();

uint8_t MESSAGE[LWS_PRE + 1024];
int MESSAGE_LENGTH = 0; // a message length of zero indicates that no message is queued

void (*FRAME_FUNCTION)() = NULL;
void (*ONOPEN_FUNCTION)() = NULL;
void (*MESSAGE_LISTENER)(RECV_MESSAGE_TYPE) = NULL;

static const struct lws_protocols PROTOCOLS[] = {
    { "rostrum-protocol", service_callback, 0, 0, },
    { NULL, NULL, 0, 0 }
};

// this has to run in a separate function because it must be scheduled by SUL
// if you call it without the scheduler, it segfaults b/c it takes a few
// iterations of the service loop to initialize everything
static void connect_client(lws_sorted_usec_list_t *sul) {
    struct lws_client_connect_info i;

    memset(&i, 0, sizeof(i));

    i.context = LWS_CONTEXT;
    i.port = SERVER_PORT;
    i.address = SERVER_ADDRESS;
    i.path = SERVER_PATH;
    i.host = i.address;
    i.origin = i.address;
    if (SERVER_SECURE) {
        i.ssl_connection = LCCSCF_USE_SSL;
    }

    lws_client_connect_via_info(&i);
}


void create_network_context() {
    struct lws_context_creation_info info;

    memset(&info, 0, sizeof(info));

    info.port = CONTEXT_PORT_NO_LISTEN; /* we do not run any server */
    info.protocols = PROTOCOLS;
    info.options = LWS_SERVER_OPTION_DO_SSL_GLOBAL_INIT;
    
#if defined(BUILD_TARGET_MACOS)
    // this is a terrible hack, but at least it's temporary
    // eventually ca cert location should be either platform specific and include everything
    // or defined in lua code
    info.client_ssl_ca_filepath = "pollywog.games.cer";
#elif defined(BUILD_TARGET_ANDROID) || defined(BUILD_TARGET_IOS)
    SDL_RWops *io = SDL_RWFromFile("pollywog.games.cer", "rb");
    if (io == NULL) {
        fprintf(stderr, "could not read ca cert from sdl rwops\n");
        return;
    }
    char ca_cert_file[io->size(io)];
    if (io->read(io, ca_cert_file, sizeof ca_cert_file, 1) <= 0) {
        fprintf(stderr, "could not read ca cert file\n");
        return;
    }
    io->close(io);
    info.client_ssl_ca_mem = ca_cert_file;
    info.client_ssl_ca_mem_len = sizeof ca_cert_file;
#else
    info.client_ssl_ca_filepath = "../pollywog.games.cer";
#endif

    info.fd_limit_per_thread = 1 + 1 + 1;

    LWS_CONTEXT = lws_create_context(&info);
    if (!LWS_CONTEXT) {
        fprintf(stderr, "lws init failed\n");
        return;
    }
}

static void one_frame(lws_sorted_usec_list_t *sul) {
    if (FRAME_FUNCTION && IS_RUNNING) {
        FRAME_FUNCTION();
        schedule_next_frame();
    }
}


// helper function for scheduling the next frame
void schedule_next_frame() {
    // TODO: calculate the frame rate in terms of target_fps
    lws_sul_schedule(LWS_CONTEXT, 0, &SUL, one_frame, LWS_USEC_PER_SEC / 60);
}

void connect_socket(
        const char* host,
        const char* path,
        int port,
        bool secure,
        void (*on_open)())
{
    SERVER_ADDRESS = host;
    SERVER_PATH = path;
    SERVER_PORT = port;
    SERVER_SECURE = secure;
    ONOPEN_FUNCTION = on_open;
    lws_sul_schedule(LWS_CONTEXT, 0, &SUL, connect_client, 1);
}

// we can't just use an infinite loop because lws_service can block
// instead we just let it do its thing and schedule frames when we need them
// this has the side effect of making FPS slightly easier to calculate
void start_network_enabled_game_loop(void (*f)(), int target_fps) {
    FRAME_FUNCTION = f;
    IS_RUNNING = true;
    
    if (!SERVER_ADDRESS) {
        // if this game doesn't use sockets, schedule the first frame now
        // otherwise, schedule the first frame after the connection has been established
        schedule_next_frame();
    }

    int n = 0;
    while (n >= 0 && IS_RUNNING) {
        n = lws_service(LWS_CONTEXT, 0);
    }
}

void send_message_on_socket(SEND_MESSAGE_TYPE msg) {
    MESSAGE_LENGTH = lws_snprintf((char*) MESSAGE + LWS_PRE, sizeof(MESSAGE) - LWS_PRE, "%s", msg);
    lws_callback_on_writable_all_protocol(LWS_CONTEXT, &PROTOCOLS[0]);
}

void set_message_listener(void (*f)(RECV_MESSAGE_TYPE)) {
    MESSAGE_LISTENER = f;
}

void close_socket() {
    lws_context_destroy(LWS_CONTEXT);
}

static int service_callback(struct lws *wsi, enum lws_callback_reasons reason, void *user, void *in, size_t len) {
    switch (reason) {

    case LWS_CALLBACK_CLIENT_CONNECTION_ERROR:
        IS_RUNNING = false;
        if (in != NULL) {
            printf("error: %s\n", in);
        }
        break;

    case LWS_CALLBACK_CLIENT_RECEIVE:
        if (MESSAGE_LISTENER) {
            MESSAGE_LISTENER((RECV_MESSAGE_TYPE) in);
        }
        break;

    case LWS_CALLBACK_CLIENT_ESTABLISHED:
        lws_callback_on_writable(wsi);
        schedule_next_frame();
        ONOPEN_FUNCTION();
        break;

    case LWS_CALLBACK_CLIENT_CLOSED:
        IS_RUNNING = false;
        printf("connection closed\n");
        break;

    case LWS_CALLBACK_CLIENT_WRITEABLE:
        // if message length is nonzero, that means a message is in the queue
        // the queue has only one slot and we don't care about dropping messages
        if (MESSAGE_LENGTH > 0) {
            int bytes_written = lws_write(wsi, MESSAGE + LWS_PRE, MESSAGE_LENGTH, LWS_WRITE_TEXT);
            if (bytes_written < MESSAGE_LENGTH ) {
                fprintf(stderr, "sending message failed: %d\n", bytes_written);
            }
            MESSAGE_LENGTH = 0;
            memset(MESSAGE, 0, sizeof(MESSAGE));
        }
        break;

    default:
        break;
    }

    return lws_callback_http_dummy(wsi, reason, user, in, len);
}


#endif
