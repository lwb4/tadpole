#ifndef network_h
#define network_h

typedef unsigned char* RECV_MESSAGE_TYPE;
typedef const char* SEND_MESSAGE_TYPE;

void connect_socket(const char* host, const char* path, int port, bool secure, void (*on_open)());
void create_network_context();
void send_message_on_socket(SEND_MESSAGE_TYPE msg);
void set_message_listener(void (*f)(RECV_MESSAGE_TYPE));
void close_socket();
void start_network_enabled_game_loop(void (*f)(), int fps);

#endif
