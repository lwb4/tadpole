#ifndef network_h
#define network_h

#define WEBSOCKET_URL "ws://localhost:8181"

typedef unsigned char* RECV_MESSAGE_TYPE;
typedef const char* SEND_MESSAGE_TYPE;

void connect_socket(void (*f)());
void send_message_on_socket(SEND_MESSAGE_TYPE msg);
void set_message_listener(void (*f)(RECV_MESSAGE_TYPE));
void close_socket();
void start_network_enabled_game_loop(void (*f)(), int fps);

#endif