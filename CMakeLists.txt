cmake_minimum_required(VERSION 3.25)
project(openframeworks VERSION 0.12.0 LANGUAGES C CXX)

# Use C++20 to fix filesystem API compatibility issues
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

# -------------------------------------------------------
# 1. Collect openFrameworks core sources
# -------------------------------------------------------
set(OF_ROOT "${CMAKE_SOURCE_DIR}/libs/openFrameworks")

# Collect all .cpp and .c files from openFrameworks subfolders
file(GLOB_RECURSE OF_CORE_SRC
        ${OF_ROOT}/**/*.cpp
        ${OF_ROOT}/**/*.c
)

# Collect all .h and .hpp files
file(GLOB_RECURSE OF_CORE_HEADERS
        ${OF_ROOT}/**/*.h
        ${OF_ROOT}/**/*.hpp
)

# Remove platform-specific files based on OS
if(WIN32)
    # Remove Linux/Unix specific files
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*ofAppEGLWindow\\.cpp$")
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*/linux/.*")
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*/android/.*")

    # Remove GStreamer files (Linux video backend)
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*ofGst.*\\.cpp$")

elseif(APPLE)
    # Remove Windows and Linux specific files
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*ofAppEGLWindow\\.cpp$")
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*/linux/.*")
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*/android/.*")
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*/win/.*")

    # Remove DirectShow files (Windows video backend)
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*ofDirectShow.*\\.cpp$")

elseif(UNIX)
    # Remove Windows and macOS specific files
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*/win/.*")
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*/osx/.*")
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*/ios/.*")
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*/android/.*")

    # Remove DirectShow files (Windows video backend)
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*ofDirectShow.*\\.cpp$")
endif()

# Only remove FMOD sound player - keep the rest for sound support
list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*ofFmodSoundPlayer\\.cpp$")

# Create an OBJECT library first to compile sources
add_library(openframeworks_obj OBJECT
        ${OF_CORE_SRC}
        ${OF_CORE_HEADERS}
)

# Now create the static library using the object library
add_library(openframeworks STATIC $<TARGET_OBJECTS:openframeworks_obj>)

# Include the openFrameworks root directory AND all subdirectories
target_include_directories(openframeworks_obj PUBLIC
        $<BUILD_INTERFACE:${OF_ROOT}>
        $<BUILD_INTERFACE:${OF_ROOT}/3d>
        $<BUILD_INTERFACE:${OF_ROOT}/app>
        $<BUILD_INTERFACE:${OF_ROOT}/communication>
        $<BUILD_INTERFACE:${OF_ROOT}/events>
        $<BUILD_INTERFACE:${OF_ROOT}/gl>
        $<BUILD_INTERFACE:${OF_ROOT}/graphics>
        $<BUILD_INTERFACE:${OF_ROOT}/math>
        $<BUILD_INTERFACE:${OF_ROOT}/sound>
        $<BUILD_INTERFACE:${OF_ROOT}/types>
        $<BUILD_INTERFACE:${OF_ROOT}/utils>
        $<BUILD_INTERFACE:${OF_ROOT}/video>
        $<INSTALL_INTERFACE:include/openframeworks>
)

target_include_directories(openframeworks PUBLIC
        $<BUILD_INTERFACE:${OF_ROOT}>
        $<BUILD_INTERFACE:${OF_ROOT}/3d>
        $<BUILD_INTERFACE:${OF_ROOT}/app>
        $<BUILD_INTERFACE:${OF_ROOT}/communication>
        $<BUILD_INTERFACE:${OF_ROOT}/events>
        $<BUILD_INTERFACE:${OF_ROOT}/gl>
        $<BUILD_INTERFACE:${OF_ROOT}/graphics>
        $<BUILD_INTERFACE:${OF_ROOT}/math>
        $<BUILD_INTERFACE:${OF_ROOT}/sound>
        $<BUILD_INTERFACE:${OF_ROOT}/types>
        $<BUILD_INTERFACE:${OF_ROOT}/utils>
        $<BUILD_INTERFACE:${OF_ROOT}/video>
        $<INSTALL_INTERFACE:include/openframeworks>
)

# -------------------------------------------------------
# 2. Find vcpkg packages
# -------------------------------------------------------
find_package(unofficial-brotli CONFIG REQUIRED)
find_package(BZip2 REQUIRED)

find_package(PkgConfig REQUIRED)
pkg_check_modules(Cairo REQUIRED IMPORTED_TARGET cairo)
pkg_check_modules(Pixman REQUIRED IMPORTED_TARGET pixman-1)

find_package(CURL CONFIG REQUIRED)
find_package(fmt CONFIG REQUIRED)
find_package(freeimage CONFIG REQUIRED)
find_package(Freetype REQUIRED)
find_package(GLEW REQUIRED)
find_package(glfw3 CONFIG REQUIRED)
find_package(glm CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)
find_package(unofficial-libtess2 CONFIG REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(pugixml CONFIG REQUIRED)
find_package(RtAudio CONFIG REQUIRED)
find_package(uriparser CONFIG REQUIRED)
find_package(utf8cpp CONFIG REQUIRED)
find_package(ZLIB REQUIRED)

if (WIN32)
    find_package(videoinput CONFIG REQUIRED)
endif()

# Add utf8cpp subdirectory to include path manually
# The package installs to utf8cpp/ but OF expects it at root
if(TARGET utf8cpp::utf8cpp)
    get_target_property(UTF8CPP_INCLUDE_DIRS utf8cpp::utf8cpp INTERFACE_INCLUDE_DIRECTORIES)
    if(UTF8CPP_INCLUDE_DIRS)
        foreach(dir ${UTF8CPP_INCLUDE_DIRS})
            if(EXISTS "${dir}/utf8cpp")
                target_include_directories(openframeworks_obj PUBLIC ${dir}/utf8cpp)
                target_include_directories(openframeworks PUBLIC ${dir}/utf8cpp)
            endif()
        endforeach()
    endif()
endif()

# -------------------------------------------------------
# 3. Link everything into openFrameworks
# -------------------------------------------------------

# Link to object library for compilation
# Use PRIVATE for CURL to avoid exporting it
target_link_libraries(openframeworks_obj PUBLIC
        unofficial::brotli::brotlienc
        unofficial::brotli::brotlidec
        unofficial::brotli::brotlicommon
        BZip2::BZip2
        PkgConfig::Cairo
        PkgConfig::Pixman
        fmt::fmt
        freeimage::FreeImage
        Freetype::Freetype
        GLEW::GLEW
        glfw
        glm::glm
        nlohmann_json::nlohmann_json
        unofficial::libtess2::libtess2
        OpenSSL::SSL
        OpenSSL::Crypto
        pugixml::pugixml
        RtAudio::rtaudio
        uriparser::uriparser
        utf8cpp::utf8cpp
        ZLIB::ZLIB
)

# CURL is PRIVATE - apps will find it themselves
target_link_libraries(openframeworks_obj PRIVATE
        CURL::libcurl
)

# Link to static library for interface (this propagates to consumers)
target_link_libraries(openframeworks PUBLIC
        unofficial::brotli::brotlienc
        unofficial::brotli::brotlidec
        unofficial::brotli::brotlicommon
        BZip2::BZip2
        PkgConfig::Cairo
        PkgConfig::Pixman
        fmt::fmt
        freeimage::FreeImage
        Freetype::Freetype
        GLEW::GLEW
        glfw
        glm::glm
        nlohmann_json::nlohmann_json
        unofficial::libtess2::libtess2
        OpenSSL::SSL
        OpenSSL::Crypto
        pugixml::pugixml
        RtAudio::rtaudio
        uriparser::uriparser
        utf8cpp::utf8cpp
        ZLIB::ZLIB
)

# CURL is PRIVATE - apps will find it themselves
target_link_libraries(openframeworks PRIVATE
        CURL::libcurl
)

if (WIN32)
    target_link_libraries(openframeworks_obj PUBLIC
            videoinput::videoinput
            opengl32
            gdi32
            winmm
            dxguid
            ole32
            oleaut32
            uuid
            strmiids
            wsock32
            ws2_32
            mfplat
            mfreadwrite
            mfuuid
    )

    target_link_libraries(openframeworks PUBLIC
            videoinput::videoinput
            opengl32
            gdi32
            winmm
            dxguid
            ole32
            oleaut32
            uuid
            strmiids
            wsock32
            ws2_32
            mfplat
            mfreadwrite
            mfuuid
    )

    target_compile_definitions(openframeworks_obj PUBLIC
            GLEW_STATIC
            NOMINMAX
            _USE_MATH_DEFINES
            WIN32_LEAN_AND_MEAN
            UNICODE
            _UNICODE
            OF_SOUND_PLAYER_MEDIA_FOUNDATION
    )

    target_compile_definitions(openframeworks PUBLIC
            GLEW_STATIC
            NOMINMAX
            _USE_MATH_DEFINES
            WIN32_LEAN_AND_MEAN
            UNICODE
            _UNICODE
            OF_SOUND_PLAYER_MEDIA_FOUNDATION
    )
elseif(APPLE)
    find_library(COCOA_LIBRARY Cocoa)
    find_library(OPENGL_LIBRARY OpenGL)
    target_link_libraries(openframeworks_obj PUBLIC
            ${COCOA_LIBRARY}
            ${OPENGL_LIBRARY}
    )
    target_link_libraries(openframeworks PUBLIC
            ${COCOA_LIBRARY}
            ${OPENGL_LIBRARY}
    )
elseif(UNIX)
    find_package(X11 REQUIRED)
    target_link_libraries(openframeworks_obj PUBLIC
            X11::X11
            X11::Xrandr
            X11::Xcursor
    )
    target_link_libraries(openframeworks PUBLIC
            X11::X11
            X11::Xrandr
            X11::Xcursor
    )
endif()

# -------------------------------------------------------
# 4. Export openframeworks for use by apps
# -------------------------------------------------------

# Export the target to a file
export(TARGETS openframeworks
        NAMESPACE openframeworks::
        FILE "${CMAKE_CURRENT_BINARY_DIR}/openframeworks-targets.cmake"
)

# Create the config file
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/openframeworks-config.cmake" "
include(CMakeFindDependencyMacro)

# Find PkgConfig first
find_dependency(PkgConfig REQUIRED)
pkg_check_modules(Cairo REQUIRED IMPORTED_TARGET cairo)
pkg_check_modules(Pixman REQUIRED IMPORTED_TARGET pixman-1)

# Find all dependencies
find_dependency(unofficial-brotli CONFIG REQUIRED)
find_dependency(BZip2 REQUIRED)
find_dependency(fmt CONFIG REQUIRED)
find_dependency(freeimage CONFIG REQUIRED)
find_dependency(Freetype REQUIRED)
find_dependency(GLEW REQUIRED)
find_dependency(glfw3 CONFIG REQUIRED)
find_dependency(glm CONFIG REQUIRED)
find_dependency(nlohmann_json CONFIG REQUIRED)
find_dependency(unofficial-libtess2 CONFIG REQUIRED)
find_dependency(OpenSSL REQUIRED)
find_dependency(pugixml CONFIG REQUIRED)
find_dependency(RtAudio CONFIG REQUIRED)
find_dependency(uriparser CONFIG REQUIRED)
find_dependency(utf8cpp CONFIG REQUIRED)
find_dependency(ZLIB REQUIRED)

if(WIN32)
    find_dependency(videoinput CONFIG REQUIRED)
endif()

# Note: CURL is not in the dependency list because it's linked privately
# Apps using openFrameworks should find CURL themselves if they need it directly

# Include the targets
include(\"\${CMAKE_CURRENT_LIST_DIR}/openframeworks-targets.cmake\")

# Set found variable
set(openframeworks_FOUND TRUE)
")

message(STATUS "openFrameworks config file created at: ${CMAKE_CURRENT_BINARY_DIR}/openframeworks-config.cmake")