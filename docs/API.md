# Tadpole Framework API

In no particular order, here are all the functions that Tadpole supports. This engine works by providing a global `lib` table to the main lua script, which contains all of the framework's functions.

On start up, Tadpole loads and runs the Lua file found out `assets/scripts/main.lua`. If you'd like to use multiple files in your project, require them from `main.lua`. After running this file, Tadpole automatically starts up the main game loop. If you have connected to a websocket, Tadpole will wait to start the game loop until the connection has been established (except for on the browser, the main loop just starts up regardless).

Tadpole also supports most of the Lua standard library by default. However, some functions will likely fail on some platforms. I'm pretty sure all file I/O functions will fail on iOS and Android. Other than that, you're on your own -- I've used the `math` package with some success, but I make no guarantees about any other packages.

My convention in this file is to indicate optional parameters with the use of a question mark following the name of the type. This is not valid Lua, and neither are the type indicators, which are found after the name of the parameter followed by a colon. All parameters without a question mark are required.

When a function fails, it cuts the function short early. There is no error handling to speak of at the moment -- just watch stderr of whatever platform you run your game on for (hopefully descriptive) error messages.

### create_websocket

```
lib.create_websocket({ host: string, path: string, port: number, secure: bool?, on_open: function? })
```

Create and connect to a websocket. It is specified in pieces rather than as a URL because string parsing is sort of tricky in C++.

* `host`: the hostname of the server to connect to
* `path`: the path following the hostname 
* `port`: the port to connect to
* `secure`: whether or not to use TLS (see NETWORKING.md)
* `on_open`: the function to call upon successfully opening the websocket

Return value: nil

### on_receive_message

```
lib.on_receive_message(f: function(msg: string))
```

Tadpole currently only supports opening a single websocket at a time. This function sets the onmessage listener for the only open websocket.

`f` accepts a string as its only parameter. If you're expecting JSON or some other type of input, you will have to parse it yourself. I have included a simple Lua JSON library in the `assets/scripts` folder that you can require if you need.

`f` is called in between frames, whenever the server sends a message back to the client.

Return value: nil

### send_message

```
lib.send_message(msg: string)
```

This function sends a UTF-8 encoded text string on the only available websocket.

Return value: nil

### fill_screen_with_color

```
lib.fill_screen_with_color(r: number, g: number, b: number)
```

Fill the entire screen with an RGB color. The parameters specify the red, green, and blue values on a scale of 0-255.

For example, white is (255, 255, 255) and black is (0, 0, 0).

Return value: nil

### load_image

```
lib.load_image(filename: string)
```

Load an image from a file and return a texture. The working directory for the file is the `assets` folder. For example, to load an image from `assets/images`, call `lib.load_image("images/your-image.png")`.

Currently, only PNG images are supported.

Return value: number (representing an index to the internal textures array)

### load_font

```
lib.load_font(filename: string)
```

Load a TrueType font from a file and return it. As with `load_image`, the working directory is the assets folder. Use the return value in `load_text` to render text.

Return value: number (representing an index to the internal fonts array)

### load_text

```
lib.load_text(font: number, text: string)
```

Render a text string as a texture using the specified font and return it.

This should wrap most strings into multiple lines. It is basically a thin wrapper around SDL's `TTF_RenderText_Blended_Wrapped`.

Return value: number (representing an index to the internal textures array)

### draw_texture

```
lib.draw_texture(x: number, y: number, texture: number)
```

Draw the specified texture onto the screen at the given X and Y coordinates. `(0,0)` is the top left corner; `(SCREEN_WIDTH, SCREEN_HEIGHT)` is the bottom right corner.

This works for both images and text, and any other type of texture that Tadpole supports in the future.

Nothing actually shows up on the screen until you call `render`.

Return value: nil

### render

```
lib.render()
```

Render all drawn textures and colors to the screen. Nothing shows up on the screen until this function is called.

Tadpole uses a `render` function rather than automatically rendering textures for performance reasons -- it helps to make images on the screen flicker less.

Return value: nil

### get_platform

```
lib.get_platform()
```

Return a string indicating which platform the script is currently running on.

Return value: string (one of `windows, mac, linux, ios, android, browser`)

### has_keyboard

```
lib.has_keyboard()
```

Determine whether or not the current platform supports keyboard input. This doesn't actually detect whether or not a keyboard is attached -- it simply returns true if the current platform is desktop or browser, and returns false for ios and android.

Return value: bool

### is_key_pressed

```
lib.is_key_pressed(keyname: string)
```

Returns true if the specified key is currently being held down, and false otherwise.

Key names are converted into scan codes using [this chart](https://wiki.libsdl.org/SDL_Scancode).

Return value: bool

### get_touch_coordinates

```
lib.get_touch_coordinates()
```

Return the coordinates of the current touch. Works the same way for both tap input on mobile and left mouse button click on all other platforms.

Return value: number, number (representing x and y coordinates respectively) if the user is either tapping the screen or clicking the left mouse button; nil, nil otherwise.

### debug

```
lib.debug(msg: string)
```

Print a message to stdout. Where stdout actually redirects to is platform specific. On Android, for example, look in Logcat for any messages with the prefix "tadpole".

Return value: nil

### load_music

```
lib.load_music(filename: string)
```

Load a sound file from a file and return it. As with `load_image`, the working directory is the `assets` folder. Use `play_music` to actually play the sound.

Currently only `.ogg` sound files are supported, and it doesn't work on the browser yet.

Return value: number (representing an index into the internal sounds array)

### play_music

```
lib.play_music(sound: number, repetitions: number)
```

Play a sound file loaded from `load_music`. The music will loop `repetitions` times. If `repetitions` is -1, loop forever.

Return value: nil

### get_screen_dimensions

```
lib.get_screen_dimensions()
```

Return the width and height of the current screen.

These values are also available via the constants `lib.SCREEN_WIDTH` and `lib.SCREEN_HEIGHT`.

Return value: number, number (for width and height respectively)

### require

```
lib.require(filename: string)
```

Load another Lua file from the working directory (the `assets` folder) and evaluate it. If there is an infinite loop in that file, this function never returns.

Tadpole uses a special require function rather than the require function from Lua's standard library because file I/O is more complicated on iOS and Android.
