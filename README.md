# Tadpole Engine

Tadpole Engine is a minimal cross-platform game development framework for making 2D networked games in Lua. It can be used to create multiplayer games on Windows, Mac OS, Linux, iPhone, iPad, Android, and the browser with the same code. The framework comes with batteries included, including project skeletons for each platform as well as scripts to cross-build dependencies from source.

My vision is that anyone will be able to create games extremely easily and instantly deploy them everywhere. I have had a great deal of pain with Unity, React Native, Godot, and other frameworks to do simple things like deployments and cross-building, and have created Tadpole to close this gap. I hope to eventually build some additional infrastructure (either CI/CD, some kind of publishing platform, hosted multiplayer services, or similar) to support this vision, in addition to this open source project.

The website for this project where you can find updates and blog posts is at https://tadpoleengine.github.io/.

I welcome any and all contributors who are interested in making my vision into a reality. If you'd like to contribute, please create an issue to track your ideas so I know what you plan to work on and we can avoid duplicating effort. If you want to contribute but don't know how or what, please create an issue anyway and I'll give you some ideas!

## Instructions

1. Clone this repo recursively (has to be recursive to get all the git submodules)
2. Create your game and put it in the `assets` directory
3. Use the provided `make.sh` script to build for Mac, iOS, Android, and Emscripten
4. Open up the generated project files, found under the `xplat` directory

On Windows, the instructions are a little more complicated.

1. Mount this repository to the Y: drive. This is necessary because I don't know how include projects in a solution via a relative path. If you know how to do this, please submit a merge request!
2. Open a Visual Studio Developer Command Prompt, cd to the Y: drive, and run make.bat. This generates the Visual Studio project files for libwebsockets. (You may have to do step 4 first if the command prompt asks you to install Visual Studio 2010 build tools.)
3. If you're using a version of Visual Studio later than 2010, you may have to right click the solution and select "retarget solution".
4. Now you can open xplat/windows/windows.sln and it should build.

If you get unexpected linker errors, make sure each project in the solution is set to x64 configuration and "/MT" for the runtime library.

Tadpole Engine itself is fairly lean but has to pull in a few dependencies to be able to compile on so many different architectures. The size may or may not be a problem, depending on the speed of your network connection. I don't plan to add any more dependencies but I make no guarantees. If you prefer, you can clone this repository regularly (not recursive) and then manually pull the submodules that you need. Proceed down that path at your own risk.

There is already a sample game in the assets directory that you can modify for your needs, or throw out entirely and build your own. The only requirement is that the assets folder contains only the folders `fonts`, `images`, `scripts`, and `sounds`, and that the `scripts` file contains a `main.lua` file which will be the entrypoint for your game. Inside of those folders you can create pretty much whatever you want. The `assets` folder is the working directory for your program, so you would load images with the path `images/character.png`, et cetera.

See the Documentation section below for a list of functions that the framework supports and what they do.

My primary computer is a Macbook Pro, so builds for that platform are most actively supported, but I am open to pull requests that add tooling support and cross-compilation for Windows and Linux.

* On any computer, you can build: browser
* On a Mac, you can build: macOS, iOS, android
* On a Windows PC, you can build: windows
* On a Linux PC, you can build: linux

There's no reason that Windows and Linux can't build for Android yet; I just use a bash script to compile their dependencies, and haven't ported that to CMake yet.

## Dependencies

All project-level dependencies are provided as git submodules and compiled from source on each platform. Dependencies are compiled into static libraries and included in each platforms' respective project files, so you shouldn't need to download any development libraries or anything.

Other than that, you need the following pieces of software:

* Mac/iOS: XCode, and brew install cmake
* Windows: Visual Studio (I built the project with community edition 2019, but anything should work)
* Linux: Nothing, unless your distro doesn't come with basic development tools like make and gcc
* Android: Android Studio, then go to SDK Manager -> install Android NDK and CMake

Certain flavors of Linux may need additional packages; for example, on Ubuntu I had to install `xorg-dev` to get rid of the "no video driver available" error from SDL.

## Documentation

TODO

## License

Tadpole Engine uses the MIT license.
