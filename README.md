# Tadpole Engine

Tadpole Engine is a minimal cross-platform game development framework for making 2D networked games in Lua. It can be used to create multiplayer games on Windows, Mac OS, Linux, iPhone, iPad, Android, and the browser with the same code. The framework comes with batteries included, including project skeletons for each platform as well as scripts to cross-build dependencies from source.

My vision is that anyone will be able to create games extremely easily and instantly deploy them everywhere. I have had a great deal of pain with Unity, React Native, Godot, and other frameworks to do simple things like deployments and cross-building, and have created Tadpole to close this gap. I hope to eventually build some additional infrastructure (either CI/CD, some kind of publishing platform, hosted multiplayer services, or similar) to support this vision, in addition to this open source project.

The website for this project where you can find updates and blog posts is at https://tadpoleengine.github.io/.

I welcome any and all contributors who are interested in making my vision into a reality. If you'd like to contribute, please create an issue to track your ideas so I know what you plan to work on and we can avoid duplicating effort. If you want to contribute but don't know how or what, please create an issue anyway and I'll give you some ideas!

## Instructions

1. Clone this repo recursively (has to be recursive to get all the git submodules)
2. Create your game and put it in the `assets` directory
3. Use the provided `toolchain.sh` script to build for Mac, iOS, Android, and Emscripten
4. Open up the generated project files, found under the `xplat` directory

Tadpole Engine itself is fairly lean but has to pull in a huge number of dependencies to be able to compile on so many different architectures. As of this writing it is 2GB and counting all together. I don't plan to add any more dependencies but I make no guarantees. If you prefer, you can clone this repository regularly (not recursive) and then manually pull the submodules that you need. Proceed down that path at your own risk.

There is already a sample game in the assets directory that you can modify for your needs, or throw out entirely and build your own. The only requirement is that the assets folder contains only the folders `fonts`, `images`, `scripts`, and `sounds`, and that the `scripts` file contains a `main.lua` file which will be the entrypoint for your game. Inside of those folders you can create pretty much whatever you want. The `assets` folder is the working directory for your program, so you would load images with the path `images/character.png` or whatever.

See the Documentation section below for a list of functions that the framework supports and what they do.

My primary computer is a Macbook Pro, so builds for that platform are most actively supported, but I am open to pull requests that add tooling support and cross-compilation for Windows and Linux.

* On any computer, you can build: browser
* On a Mac, you can build: macOS, iOS, android
* On a Windows PC, you can build: windows
* On a Linux PC, you can build: linux

## Dependencies

Some dependencies are provided as source code in submodules to this project, but there are a few packages that you have to download and manage yourself.

I maintain a fork of liwebsockets that includes a lean patch to make it work on iOS. I also maintain unofficial Github mirrors of the MinGW development binaries for SDL2, SDL2_ttf, SDL2_mixer, and SDL2_image. 

Ideally, almost everything would be compiled from source and statically linked for each platform, but I'm not there yet. That is another area I would accept pull requests in.

To build for Android, you need to download Android Studio and install the SDK, the NDK, and CMake.

To build for Apple platforms, you need to download the latest version of Xcode.

To build for Mac OS, you need to download the development libraries for [SDL2](https://libsdl.org/download-2.0.php), [SDL2_ttf](https://www.libsdl.org/projects/SDL_ttf/), [SDL2_image](https://www.libsdl.org/projects/SDL_image/), and [SDL2_mixer](https://www.libsdl.org/projects/SDL_mixer/). You also have to `brew install openssl` if you don't have it already. These would be ideal candidates for static linking, so you don't have to download the libraries separately.

To build for Linux, you have to install several development libraries from your distribution's package manager. On Ubuntu, you can simply `apt-install xorg-dev libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev libssl-dev`. I also provide a Code::Blocks project file out of the box, although this could probably be replaced

To build for Windows, you have to install MinGW and Code::Blocks. Again, Code::Blocks could probably be replaced with plain old Make files, or possibly CMake, but this is just how I have set it up so far. I have checked the runtime libraries into source control, for better or for worse, so you can find those DLLs deeply nested somewhere in the `xplat/windows` directory tree. Lastly, you have to manually build libwebsockets following the instructions at `deps/windows-libwebsockets/BUILD.md`.

Most of this installation pain is stuff that can and should be automated away. I have very little experience developing for Windows, so that process is the most laborious and manual. 

## Documentation

TODO

## License

Tadpole Engine uses the MIT license.
