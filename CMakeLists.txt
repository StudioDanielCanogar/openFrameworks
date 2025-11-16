cmake_minimum_required(VERSION 3.25)
project(openframeworks VERSION 0.12.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

# -------------------------------------------------------
# 1. Collect openFrameworks core sources
# -------------------------------------------------------
set(OF_ROOT "${CMAKE_SOURCE_DIR}/libs/openFrameworks")

file(GLOB_RECURSE OF_CORE_SRC ${OF_ROOT}/**/*.cpp ${OF_ROOT}/**/*.c)
file(GLOB_RECURSE OF_CORE_HEADERS ${OF_ROOT}/**/*.h ${OF_ROOT}/**/*.hpp)

# Remove platform-specific files
if(WIN32)
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*ofAppEGLWindow\\.cpp$")
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*/linux/.*|.*/android/.*")
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*ofGst.*\\.cpp$")
elseif(APPLE)
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*ofAppEGLWindow\\.cpp$")
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*/linux/.*|.*/android/.*|.*/win/.*")
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*ofDirectShow.*\\.cpp$")
elseif(UNIX)
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*/win/.*|.*/osx/.*|.*/ios/.*|.*/android/.*")
    list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*ofDirectShow.*\\.cpp$")
endif()

list(FILTER OF_CORE_SRC EXCLUDE REGEX ".*ofFmodSoundPlayer\\.cpp$")

# -------------------------------------------------------
# 2. Create library (no OBJECT library needed)
# -------------------------------------------------------
add_library(openframeworks STATIC ${OF_CORE_SRC} ${OF_CORE_HEADERS})

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
# 3. Find packages
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

if(WIN32)
    find_package(videoinput CONFIG REQUIRED)
endif()

# Handle utf8cpp include path
if(TARGET utf8cpp::utf8cpp)
    get_target_property(UTF8CPP_INCLUDE_DIRS utf8cpp::utf8cpp INTERFACE_INCLUDE_DIRECTORIES)
    if(UTF8CPP_INCLUDE_DIRS)
        foreach(dir ${UTF8CPP_INCLUDE_DIRS})
            if(EXISTS "${dir}/utf8cpp")
                target_include_directories(openframeworks PUBLIC ${dir}/utf8cpp)
            endif()
        endforeach()
    endif()
endif()

# -------------------------------------------------------
# 4. Link libraries
# -------------------------------------------------------
# CURL is PRIVATE to avoid export issues
target_link_libraries(openframeworks PRIVATE CURL::libcurl)

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

if(WIN32)
    target_link_libraries(openframeworks PUBLIC
            videoinput::videoinput
            opengl32 gdi32 winmm dxguid ole32 oleaut32
            uuid strmiids wsock32 ws2_32
            mfplat mfreadwrite mfuuid
    )
    target_compile_definitions(openframeworks PUBLIC
            GLEW_STATIC NOMINMAX _USE_MATH_DEFINES
            WIN32_LEAN_AND_MEAN UNICODE _UNICODE
            OF_SOUND_PLAYER_MEDIA_FOUNDATION
    )
elseif(APPLE)
    find_library(COCOA_LIBRARY Cocoa)
    find_library(OPENGL_LIBRARY OpenGL)
    target_link_libraries(openframeworks PUBLIC ${COCOA_LIBRARY} ${OPENGL_LIBRARY})
elseif(UNIX)
    find_package(X11 REQUIRED)
    target_link_libraries(openframeworks PUBLIC X11::X11 X11::Xrandr X11::Xcursor)
endif()

# -------------------------------------------------------
# 5. Export
# -------------------------------------------------------
export(TARGETS openframeworks
        NAMESPACE openframeworks::
        FILE "${CMAKE_CURRENT_BINARY_DIR}/openframeworks-targets.cmake"
)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/openframeworks-config.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(PkgConfig REQUIRED)
pkg_check_modules(Cairo REQUIRED IMPORTED_TARGET cairo)
pkg_check_modules(Pixman REQUIRED IMPORTED_TARGET pixman-1)
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
include(\"\${CMAKE_CURRENT_LIST_DIR}/openframeworks-targets.cmake\")
set(openframeworks_FOUND TRUE)
")

message(STATUS "openFrameworks configured successfully")