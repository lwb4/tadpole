#include "global.h"
#include "network.h"
#include <stdio.h>
#include <stdlib.h>

#ifdef BUILD_TARGET_ANDROID
#include <pthread.h>
#endif

extern bool IS_RUNNING;

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
    emscripten_websocket_send_utf8_text(ws, msg);
}

void set_message_listener(void (*f)(RECV_MESSAGE_TYPE)) {
    ONMESSAGE_FUNCTION = f;
}

void close_socket() {
    emscripten_websocket_close(ws, 1000, "done");
    emscripten_websocket_delete(ws);
}

void connect_socket(void (*f)()) {
    struct EmscriptenWebSocketCreateAttributes attr;
    attr.url = WEBSOCKET_URL;
    attr.protocols = NULL;
    attr.createOnMainThread = 1;
    ws = emscripten_websocket_new(&attr);
    if (ws < 0) {
        fprintf(stderr, "could not create websocket\n");
    }
    ONOPEN_FUNCTION = f;
    emscripten_websocket_set_onopen_callback(ws, NULL, onopen);
}

void start_network_enabled_game_loop(void (*f)(), int target_fps) {
    // A basic main loop to prevent blocking
    // Emscripten can't handle loops. See https://emscripten.org/docs/porting/emscripten-runtime-environment.html#browser-main-loop
    emscripten_set_main_loop(f, target_fps, 1);
}

#else

extern "C" {
#include <libwebsockets.h>
}

// all other platforms use libwebsockets (LWS)
// it is a little bit tricky to come up with a unified internal API for
// accessing websockets through both Emscripten Websockets and LWS,
// hence some quirkiness in these function signatures.

lws_sorted_usec_list_t  SUL;

static struct lws_context *CONTEXT;
static int SERVER_PORT = 8181;
#ifdef BUILD_TARGET_ANDROID
static const char *SERVER_ADDRESS = "10.0.2.2";
#else
static const char *SERVER_ADDRESS = "localhost";
#endif
static const char *SERVER_PATH = "/";

static int service_callback(struct lws *wsi, enum lws_callback_reasons reason, void *user, void *in, size_t len);
static void one_frame(lws_sorted_usec_list_t *sul);
void schedule_next_frame();

uint8_t MESSAGE[LWS_PRE + 1024];
int MESSAGE_LENGTH = 0; // a message length of zero indicates that no message is queued

void (*FRAME_FUNCTION)() = NULL;
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

    i.context = CONTEXT;
    i.port = SERVER_PORT;
    i.address = SERVER_ADDRESS;
    i.path = SERVER_PATH;
    i.host = i.address;
    i.origin = i.address;

    lws_client_connect_via_info(&i);
}


void connect_socket(void (*f)()) {
    struct lws_context_creation_info info;

    memset(&info, 0, sizeof(info));

    info.port = CONTEXT_PORT_NO_LISTEN; /* we do not run any server */
    info.protocols = PROTOCOLS;

    info.fd_limit_per_thread = 1 + 1 + 1;

    CONTEXT = lws_create_context(&info);
    if (!CONTEXT) {
        fprintf(stderr, "lws init failed\n");
        return;
    }

    f();
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
    lws_sul_schedule(CONTEXT, 0, &SUL, one_frame, LWS_USEC_PER_SEC / 60);
}

// we can't just use an infinite loop because lws_service can block
// instead we just let it do its thing and schedule frames when we need them
// this has the side effect of making FPS slightly easier to calculate
void start_network_enabled_game_loop(void (*f)(), int target_fps) {
    FRAME_FUNCTION = f;
    IS_RUNNING = true;
    lws_sul_schedule(CONTEXT, 0, &SUL, connect_client, 1);

    int n = 0;
    while (n >= 0 && IS_RUNNING) {
        n = lws_service(CONTEXT, 0);
    }
}

void send_message_on_socket(SEND_MESSAGE_TYPE msg) {
    MESSAGE_LENGTH = lws_snprintf((char*) MESSAGE + LWS_PRE, sizeof(MESSAGE) - LWS_PRE, "%s", msg);
    lws_callback_on_writable_all_protocol(CONTEXT, &PROTOCOLS[0]);
}

void set_message_listener(void (*f)(RECV_MESSAGE_TYPE)) {
    MESSAGE_LISTENER = f;
}

void close_socket() {
    lws_context_destroy(CONTEXT);
}

static int service_callback(struct lws *wsi, enum lws_callback_reasons reason, void *user, void *in, size_t len) {
    switch (reason) {

    case LWS_CALLBACK_CLIENT_RECEIVE:
        if (MESSAGE_LISTENER) {
            MESSAGE_LISTENER((RECV_MESSAGE_TYPE) in);
        }
        break;

    case LWS_CALLBACK_CLIENT_ESTABLISHED:
        lws_callback_on_writable(wsi);
        schedule_next_frame();
        break;

    case LWS_CALLBACK_CLIENT_CLOSED:
        // TODO: some error handling here
        printf("connection closed");
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
