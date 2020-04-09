# Tadpole Engine

Tadpole Engine is a minimal cross-platform game development framework for making 2D networked games in Lua. It can be used to create multiplayer games on Windows, Mac OS, Linux, iPhone, iPad, Android, and the browser with the same code. Rather than providing a GUI in the way that Unity and Godot do, all games are made purely from Lua code in whatever text editor you prefer. After writing your game in Lua, open the project skeletons under the xplat directory and build your project from there.

My vision is that anyone will be able to create games extremely easily and instantly deploy them everywhere. I have had a great deal of pain with Unity and React Native and other frameworks to do simple things like deployments and cross-building, and have created Tadpole to close this gap. I hope to eventually build some additional infrastructure (either CI/CD, some kind of publishing platform, hosted multiplayer services, or similar) to support this vision, in addition to this open source project.

The website for this project where you can find updates and blog posts is at https://tadpoleengine.github.io/.

I welcome any and all contributors who are interested in making my vision into a reality. If you'd like to contribute, please create an issue to track your ideas so I know what you plan to work on and we can avoid duplicating effort. If you want to contribute but don't know how or what, please create an issue anyway and I'll give you some ideas!

View the CI pipelines for Tadpole on [Travis](https://travis-ci.org/github/lwb4/tadpole) and [AppVeyor](https://ci.appveyor.com/project/lwb4/tadpole).

## Installation

On Mac and Linux, follow these steps:

1. Clone this repo recursively (has to be recursive to get all the git submodules).
2. Create your game and put it in the `assets` directory.
3. Use the provided `make.sh` script to build for Mac, iOS, Linux, Android, and Emscripten.
4. Open up the generated project files, found under the `xplat` directory.

When building for Emscripten, you will likely want to run `source ./make.sh browser` rather than just `./make.sh browser`, because installing EMSDK adds the Emscripten toolchain to your PATH. Without the `source` preceding the command name, changes to your PATH won't persist after the command finishes running.

On Windows, follow these steps:

1. Clone this repo recursively.
2. Open a Visual Studio Developer Command Prompt, cd to where you cloned this repository, and run make.bat. This generates the Visual Studio project files for libwebsockets.
3. Depending on your version of Visual Studio, you may have to right click the solution and select "retarget solution".
4. Now you can open xplat/windows/windows.sln and it should build.

Tadpole Engine itself is fairly lean but has to pull in a few dependencies to be able to compile on so many different architectures. The size may or may not be a problem, depending on the speed of your network connection. I don't plan to add any more dependencies but I make no guarantees. If you prefer, you can clone this repository regularly (not recursive) and then manually pull the submodules that you need. Proceed down that path at your own risk.

There is already a sample game in the assets directory that you can modify for your needs, or throw out entirely and build your own. The only requirement is that the assets folder contains only the folders `fonts`, `images`, `scripts`, and `sounds`, and that the `scripts` file contains a `main.lua` file which will be the entrypoint for your game. Inside of those folders you can create pretty much whatever you want. The `assets` folder is the working directory for your program, so you would load images with the path `images/character.png`, et cetera.

My primary computer is a Macbook Pro, so builds for that platform are most actively supported, but I am open to pull requests that add tooling support and cross-compilation for Windows and Linux.

* On any computer, you can build: browser
* On a Mac, you can build: macOS, iOS, android
* On a Windows PC, you can build: windows
* On a Linux PC, you can build: linux

There's no reason that Windows and Linux can't build for Android yet; I just use a bash script to compile Android dependencies, and haven't ported that to CMake yet.

## Dependencies

All project-level dependencies are provided as git submodules and compiled from source on each platform. Dependencies are compiled into static libraries and included in each platforms' respective project files, so you shouldn't need to download any development libraries or anything.

To build Tadpole projects, you will need the following pieces of software:

* Mac/iOS: XCode, and brew install cmake
* Windows: Visual Studio (I built the project with community edition 2019, but anything should work)
* Linux: cmake, GNU make and autotools, and libfreetype (on Ubuntu this is libfreetype6-dev), probably also libvorbis-dev, libogg-dev, libasound2-dev, libpulse-dev, maybe some others
* Android: Android Studio, then go to SDK Manager -> install Android NDK and CMake

Certain flavors of Linux may need additional packages; for example, on Ubuntu I had to install `xorg-dev` to get rid of the "no video driver available" error from SDL.

## Documentation

TODO

## License

Tadpole Engine uses the MIT license.
