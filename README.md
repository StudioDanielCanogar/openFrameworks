openFrameworks + CMake + vcpkg
================
<!-- TOC -->

- [openFrameworks + CMake + vcpkg](#openframeworks--cmake--vcpkg)
    - [Status](#status)
    - [Setup and Build](#setup-and-build)
        - [With CLion](#with-clion)
        - [With the command line](#with-the-command-line)
    - [Addons](#addons)
    - [Structure](#structure)
    - [Disclaimers](#disclaimers)

<!-- /TOC -->

This is an openFrameworks branch that adds a CMake build system and uses vcpkg to manage OF's dependencies. It builds
upon [c-mendoza's cmake branch](https://github.com/c-mendoza/openFrameworks/tree/cmake), but integrates vcpkg as a way
to completely replace the Apothecary.

The goals of fork are:

* Replace Apothecary with vcpkg on desktop platforms.
* Be a true cross-platform build system, but primarily focused on desktop platforms.
* Obviate the need for the Project Generator: addons are added in your project's CMakeLists file using a single
  function.
* Enabling the use of CMake-compatible IDE's like CLion and VS Code.
* Make openFrameworks an easily installable package, enabling its integration into other
  projects (imagine OF in a JUCE app, for example).

## Status

| Platform | Status | Notes                         |
|:--------:|:------:|-------------------------------|
|  MacOS   |   ✅    | Only tested on Sequoia (15.6) |
| Windows  |   ✅️   | VS only (no msys2).           | 
|  Linux   |   ❌    | Not started yet.              |


## Setup and Build

1. Clone this branch.
2. Initialize submodules: `git submodule update --init --recursive`. vcpkg is a submodule, so this is necessary.
3. In the terminal, `cd thirdParty/vcpkg`
4. Run `./bootstrap-vcpkg` (sh or bat depending on your OS).

### With CLion

I highly recommend using [CLion](https://www.jetbrains.com/clion/) as an IDE!

1. In the openFrameworks root directory, open `CMakeLists.txt` and **open it as a Project**.
2. Two CMake profiles should be added via presets: `vcpkg-debug` and `vcpkg-release`.
3. At this point, CMake should automatically be called by CLion to config the project. If it doesn't, in the app menu,
   select `Tools` > `CMake` > `Reload CMake Project`.
4. vcpkg will now download and build the OF dependencies. This will take a while, so if you are using a laptop, consider
   plugging it in.

Now we will build the test ofApp, which will also trigger the build of the OF library:

1. From `tests/cmake/cmakeTest`, open `CMakeLists.txt` and **open it as a Project**.
7. Create a Debug and a Release config.
8. Select the Debug config, select `cmakeTest` as a target and press the Run button.

### With the command line

1. Open a terminal in the openFrameworks root directory and type the following:

```
cmake -DCMAKE_BUILD_TYPE=Debug --preset vcpkg-debug -S . -B vcpkg-build-debug
```

That should configure the project, then download and build the OF dependencies. Again, this will take a while!

2. Once this is done, in the terminal, change directory to `tests/cmake/cmakeTest`
3. Now configure and build the debug version:

```
cmake -DCMAKE_BUILD_TYPE=Debug -B cmake-build-debug
cmake --build cmake-build-debug --target cmakeTest -j 8
```

4. You can also build the release version:

```
cmake -DCMAKE_BUILD_TYPE=Release -B cmake-build-release
cmake --build cmake-build-release --target cmakeTest -j 8
```

## Addons

* There is limited addon support in the app's CMakeLists file via the function
  `ofIncludeAddon`. The system is able to load addons
  that follow the "standard" addon file structure and which don't require anything other than compilation of sources and
  linking to provided libraries.
    * This means that not every addon will
      work! For the moment, any sources and headers that `ofIncludeAddon` doesn't pick up can be
      added manually in your app's `CMakeLists.txt`.
* Addons can be *global* (from the `openFrameworks/addons` folder) or
  *local* (the addon's folder is located in the root of your ofApp project).
    * When an addon exists both locally and globally, the local addon is given preference by `ofIncludeAddon`.
* Take a look at `tests/cmake/cmakeWithAddon` for an example.


## Structure

The fork adds the following files:

- At the openFrameworks root:
    - `CMakeLists.txt`: The CMake project file, configures and builds the OF library and creates the installation rules.
    - `vcpkg.json` and `vcpkg-configuration.json`, which set declare the OF dependencies and configure vcpkg.
    - `CMakePresets.json`: Creates the CMake profiles.
- An `overlay-ports` folder.
- A `cmake` folder that contains some helper files.
  `of_macros.cmake` is the most interesting one at the moment.
- A `tests/cmake` folder, which has tests/examples of the build system.

## Disclaimers

I am not a CMake expert, so any suggestions for improvements are welcome!