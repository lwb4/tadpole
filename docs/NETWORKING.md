# Networking

Tadpole uses two different networking backends: libwebsockets for all platforms that support it, and Emscripten WebSockets for the browser.

libwebsockets is written in pure C and can do just about any networking related function. Besides just websockets, libwebsockets can also do HTTP, HTTPS, UDP, and TCP.

Unfortunately, the Emscripten WebSockets API is much more limited -- it only supports websockets. However, Emscripten does provide socket emulation out of the box; it's just really tricky to get it to work right. Since browser targets only have access to the underlying APIs that the browser supports natively, all communication over sockets is proxied through WebSockets under the hood. Emscripten's official docs recommend using Websockify to convert traffic between WebSockets and regular TCP/UDP. I haven't been able to figure that out yet but it's certainly doable.

If you want to expand Tadpole's networking functionality, for example by building a sub-protocol on top of UDP (I believe this is what most multiplayer games do these days), I support you 100% -- however, just know that there are complications in browser land.

## TLS

Tadpole supports secure websockets out of the box.

In the browser, Emscripten actually makes this incredibly easy -- just say your protocol is `wss` instead of `ws` and you're already done.

It's not so easy to do with libwebsockets. Tadpole compiles libwebsockets with the mbedTLS encryption library, which requires that you provide your own CA cert chain. I have checked the CA cert chain for my company's website (pollywog.games) into the xplat directory. This means however that you can only communicate securely with pollywog.games and no other websites.

I don't know a ton about this stuff, but I'm pretty sure that each operating system provides a CA cert chain that Tadpole could just point to if I knew where it was. Until I get that figured out, you can connect a regular WebSocket to any website, but a secure WebSocket only with pollywog.games.
