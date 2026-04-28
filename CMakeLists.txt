cmake_minimum_required(VERSION 3.28)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
set(CMAKE_CONFIGURATION_TYPES "RelWithDebInfo;Debug;Release;")

# Use C++20 to fix filesystem API compatibility issues
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#if (CMAKE_CURRENT_LIST_DIR STREQUAL CMAKE_SOURCE_DIR)
#endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
set(OF_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
include(of_macros)

project(openFrameworks)

#set(VCPKG_ROOT ${OF_DIRECTORY}/thirdParty/vcpkg)
#set(CMAKE_TOOLCHAIN_FILE "${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
#message(STATUS "------------------------\n${CMAKE_TOOLCHAIN_FILE}")



# --------------------------------------------------
# Installation prefix: {OF_DIRECTORY}/install/{platform}
# --------------------------------------------------
#ofSetInstallPrefix()
# --------------------------------------------------
# Source Files
# --------------------------------------------------

file(GLOB_RECURSE SRC_3D "${OF_DIRECTORY}/libs/openFrameworks/3d/*.cpp")
set(SRC_APP
        ${OF_DIRECTORY}/libs/openFrameworks/app/ofAppGLFWWindow.cpp
        ${OF_DIRECTORY}/libs/openFrameworks/app/ofBaseApp.cpp
        ${OF_DIRECTORY}/libs/openFrameworks/app/ofAppNoWindow.cpp
        ${OF_DIRECTORY}/libs/openFrameworks/app/ofAppRunner.cpp
        ${OF_DIRECTORY}/libs/openFrameworks/app/ofMainLoop.cpp
)
file(GLOB_RECURSE SRC_COMMS "${OF_DIRECTORY}/libs/openFrameworks/communication/*.cpp")
file(GLOB_RECURSE SRC_EVENTS "${OF_DIRECTORY}/libs/openFrameworks/events/*.cpp")
file(GLOB_RECURSE SRC_GRAPHICS "${OF_DIRECTORY}/libs/openFrameworks/graphics/*.cpp")
file(GLOB_RECURSE SRC_GL "${OF_DIRECTORY}/libs/openFrameworks/gl/*.cpp")
file(GLOB_RECURSE SRC_MATH "${OF_DIRECTORY}/libs/openFrameworks/math/*.cpp")
set(SRC_SOUND
        ${OF_DIRECTORY}/libs/openFrameworks/sound/ofFmodSoundPlayer.cpp
        #        ${OF_DIRECTORY}/libs/openFrameworks/sound/ofOpenALSoundPlayer.cpp
        ${OF_DIRECTORY}/libs/openFrameworks/sound/ofSoundBuffer.cpp
        ${OF_DIRECTORY}/libs/openFrameworks/sound/ofSoundPlayer.cpp
        ${OF_DIRECTORY}/libs/openFrameworks/sound/ofSoundStream.cpp
        ${OF_DIRECTORY}/libs/openFrameworks/sound/ofSoundBaseTypes.cpp
)
file(GLOB_RECURSE SRC_TYPES "${OF_DIRECTORY}/libs/openFrameworks/types/*.cpp")
file(GLOB_RECURSE SRC_UTILS "${OF_DIRECTORY}/libs/openFrameworks/utils/*.cpp")
set(SRC_VIDEO
        ${OF_DIRECTORY}/libs/openFrameworks/video/ofVideoGrabber.cpp
        ${OF_DIRECTORY}/libs/openFrameworks/video/ofVideoPlayer.cpp
)

set(OF_SRC)

list(APPEND OF_SRC
        ${SRC_3D}
        ${SRC_APP}
        ${SRC_COMMS}
        ${SRC_EVENTS}
        ${SRC_GRAPHICS}
        ${SRC_GL}
        ${SRC_MATH}
        ${SRC_SOUND}
        ${SRC_TYPES}
        ${SRC_UTILS}
        ${SRC_VIDEO}
)

# --------------------------------------------------
# Append platform specific files
# --------------------------------------------------

if (APPLE)
    list(APPEND OF_SRC
            ${OF_DIRECTORY}/libs/openFrameworks/video/ofAVFoundationVideoPlayer.m
            ${OF_DIRECTORY}/libs/openFrameworks/video/ofAVFoundationPlayer.mm
            ${OF_DIRECTORY}/libs/openFrameworks/video/ofAVFoundationGrabber.mm
            ${OF_DIRECTORY}/libs/openFrameworks/sound/ofAVEngineSoundPlayer.h
            ${OF_DIRECTORY}/libs/openFrameworks/sound/ofAVEngineSoundPlayer.mm
            ${OF_DIRECTORY}/libs/openFrameworks/sound/ofRtAudioSoundStream.cpp

    )
elseif (WIN32)
    list(APPEND OF_SRC
            ${OF_DIRECTORY}/libs/openFrameworks/video/ofDirectShowGrabber.cpp
            ${OF_DIRECTORY}/libs/openFrameworks/video/ofDirectShowPlayer.cpp
            ${OF_DIRECTORY}/libs/openFrameworks/video/ofMediaFoundationPlayer.cpp
            ${OF_DIRECTORY}/libs/openFrameworks/sound/ofMediaFoundationSoundPlayer.cpp
            ${OF_DIRECTORY}/libs/openFrameworks/sound/ofRtAudioSoundStream.cpp

    )
endif ()

#foreach (item IN LISTS OF_SRC)
#    message(STATUS " - ${item}")
#endforeach ()

# --------------------------------------------------
# Target
# --------------------------------------------------

add_library(of_static STATIC ${OF_SRC})

# --------------------------------------------------
# Export & Install
# --------------------------------------------------

include(CMakePackageConfigHelpers)

find_package(unofficial-brotli CONFIG REQUIRED)
find_package(BZip2 REQUIRED)

#find_package(PkgConfig REQUIRED)
#pkg_check_modules(CAIRO REQUIRED IMPORTED_TARGET cairo)
#pkg_check_modules(PIXMAN REQUIRED IMPORTED_TARGET pixman-1)
#pkg_check_modules(LIBUSB REQUIRED IMPORTED_TARGET libusb-1.0)

if (WIN32)
    # On Windows, link directly to the libraries
    find_library(CAIRO_LIB NAMES cairo REQUIRED)
    find_library(PIXMAN_LIB NAMES pixman-1 REQUIRED)
    find_library(LIBUSB_LIB NAMES libusb-1.0 usb-1.0 REQUIRED)

    # Create interface targets for consistency
    add_library(Cairo::Cairo INTERFACE IMPORTED)
    target_link_libraries(Cairo::Cairo INTERFACE ${CAIRO_LIB})

    add_library(Pixman::Pixman INTERFACE IMPORTED)
    target_link_libraries(Pixman::Pixman INTERFACE ${PIXMAN_LIB})

    add_library(libusb::libusb INTERFACE IMPORTED)
    target_link_libraries(libusb::libusb INTERFACE ${LIBUSB_LIB})
else ()
    # On Unix, use pkg-config
    find_package(PkgConfig REQUIRED)

    pkg_check_modules(CAIRO REQUIRED IMPORTED_TARGET cairo)
    pkg_check_modules(PIXMAN REQUIRED IMPORTED_TARGET pixman-1)
    pkg_check_modules(LIBUSB REQUIRED IMPORTED_TARGET libusb-1.0)

    # Create consistent interface targets
    add_library(Cairo::Cairo ALIAS PkgConfig::CAIRO)
    add_library(Pixman::Pixman ALIAS PkgConfig::PIXMAN)
    add_library(libusb::libusb ALIAS PkgConfig::LIBUSB)
endif ()

find_package(CURL REQUIRED)
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


## Propagate include dirs for pkg-config-only deps
#if (cairo_FOUND)
#    target_include_directories(of_static PUBLIC ${cairo_INCLUDE_DIRS})
#endif()
#if (libusb_FOUND)
#    target_include_directories(of_static PUBLIC ${libusb_INCLUDE_DIRS})
#endif()

# Optional: propagate other CFLAGS from pkg-config if needed
target_compile_options(of_static PRIVATE ${cairo_CFLAGS_OTHER} ${libusb_CFLAGS_OTHER})

# Use PkgConfig::CAIRO instead of manual interface
if (NOT WIN32)
    target_link_libraries(of_static PUBLIC PkgConfig::CAIRO)
    target_link_libraries(of_static PUBLIC PkgConfig::PIXMAN)
    target_link_libraries(of_static PUBLIC PkgConfig::LIBUSB)
endif ()
target_link_libraries(of_static PRIVATE unofficial::brotli::brotlidec)
target_link_libraries(of_static PRIVATE unofficial::brotli::brotlienc)
target_link_libraries(of_static PRIVATE unofficial::brotli::brotlicommon)
target_link_libraries(of_static PRIVATE ZLIB::ZLIB)
target_link_libraries(of_static PRIVATE PNG::PNG)
target_link_libraries(of_static PRIVATE Freetype::Freetype)
target_link_libraries(of_static PRIVATE OpenSSL::SSL)
target_link_libraries(of_static PRIVATE OpenSSL::Crypto)
target_link_libraries(of_static PRIVATE CURL::libcurl)
target_link_libraries(of_static PRIVATE fmt::fmt)
target_link_libraries(of_static PRIVATE freeimage::FreeImage)
if (TARGET GLEW::glew_s)
    target_link_libraries(of_static PUBLIC GLEW::glew_s)
elseif (TARGET GLEW::GLEW)
    target_link_libraries(of_static PUBLIC GLEW::GLEW)
else ()
    message(FATAL_ERROR "Could not find GLEW target")
endif ()
target_link_libraries(of_static PRIVATE glfw)
target_link_libraries(of_static PRIVATE glm::glm-header-only)
target_link_libraries(of_static PRIVATE unofficial::libtess2::libtess2)
target_link_libraries(of_static PRIVATE nlohmann_json::nlohmann_json)
#if (OF_TARGET_MACOS)
target_link_libraries(of_static PRIVATE pugixml::static pugixml::pugixml)
#else ()
#    target_link_libraries(of_static PRIVATE pugixml::shared pugixml::pugixml)
#endif ()
target_link_libraries(of_static PRIVATE RtAudio::rtaudio)
target_link_libraries(of_static PRIVATE uriparser::uriparser)
target_link_libraries(of_static PRIVATE utf8::cpp utf8cpp::utf8cpp)


# Only override prefix for LOCAL builds, never inside vcpkg
# vcpkg sets CMAKE_INSTALL_PREFIX itself, so don't override it
#if(NOT DEFINED VCPKG_TARGET_TRIPLET)
#    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
#        set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/install" CACHE PATH "" FORCE)
#        message(STATUS "Setting install prefix to: ${CMAKE_INSTALL_PREFIX}")
#    endif()
#else()
#    message(STATUS "vcpkg detected - using vcpkg install prefix: ${CMAKE_INSTALL_PREFIX}")
#endif()

# Install the library
install(TARGETS of_static
        EXPORT openframeworksTargets
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        RUNTIME DESTINATION bin
)

#message(STATUS "--INSTALL PREFIX = ${CMAKE_INSTALL_PREFIX}")
# Install headers - using absolute path with correct case
install(DIRECTORY "${OF_DIRECTORY}/libs/openFrameworks/"
        DESTINATION include/openFrameworks
        FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hpp"
        PATTERN "*.inl"
        PATTERN "*.mm"
        PATTERN "*.m"
)

# Install export targets
install(EXPORT openframeworksTargets
        FILE openframeworksTargets.cmake
        NAMESPACE openframeworks::
        DESTINATION lib/cmake/openframeworks
)

# Generate and install config files
configure_package_config_file(
        ${CMAKE_CURRENT_LIST_DIR}/cmake/openframeworksConfig.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/openframeworksConfig.cmake
        INSTALL_DESTINATION lib/cmake/openframeworks
)

write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/openframeworksConfigVersion.cmake
        VERSION 0.1.0
        COMPATIBILITY SameMajorVersion
)

install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/openframeworksConfig.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/openframeworksConfigVersion.cmake
        DESTINATION lib/cmake/openframeworks
)

# Install shaders
install(DIRECTORY "${OF_DIRECTORY}/libs/openFrameworks/gl/shaders/"
        DESTINATION share/openframeworks/shaders
        FILES_MATCHING
        PATTERN "*.frag"
        PATTERN "*.vert"
        PATTERN "*.glsl"
)

# These don't seem to work
set_target_properties(of_static PROPERTIES
        OUTPUT_NAME "openframeworksLib$<$<CONFIG:Debug>:_debug>"
        CXX_STANDARD 20
        CXX_STANDARD_REQUIRED ON
        C_STANDARD 17
        C_STANDARD_REQUIRED ON
)

#add_custom_command(TARGET of_static POST_BUILD
#        COMMAND ${CMAKE_COMMAND} --install ${CMAKE_BINARY_DIR}
#        COMMENT "Installing openframeworks after build"
#)

if (OF_TARGET_MACOS)
    # These don't seem to work
    set_target_properties(of_static PROPERTIES
            OBJCXX_STANDARD 20
            OBJC_STANDARD 17
    )
endif ()

# This seems to be the only thing that sets the c++ standard...
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)


# -------------------------------------------------- #
# Includes                                           #
# -------------------------------------------------- #


set(OF_HEADERS
        ${OF_DIRECTORY}/libs/openFrameworks/
        ${OF_DIRECTORY}/libs/openFrameworks/3d
        ${OF_DIRECTORY}/libs/openFrameworks/app
        ${OF_DIRECTORY}/libs/openFrameworks/communication
        ${OF_DIRECTORY}/libs/openFrameworks/events
        ${OF_DIRECTORY}/libs/openFrameworks/events
        ${OF_DIRECTORY}/libs/openFrameworks/gl
        ${OF_DIRECTORY}/libs/openFrameworks/graphics
        ${OF_DIRECTORY}/libs/openFrameworks/math
        ${OF_DIRECTORY}/libs/openFrameworks/sound
        ${OF_DIRECTORY}/libs/openFrameworks/types
        ${OF_DIRECTORY}/libs/openFrameworks/utils
        ${OF_DIRECTORY}/libs/openFrameworks/video
)

# Publish public headers to dependents (build tree and install tree)
# Publish public headers to dependents (build tree and install tree)
target_include_directories(of_static PUBLIC
        $<BUILD_INTERFACE:${OF_DIRECTORY}/libs/openFrameworks>
        $<BUILD_INTERFACE:${OF_DIRECTORY}/libs/openFrameworks/3d>
        $<BUILD_INTERFACE:${OF_DIRECTORY}/libs/openFrameworks/app>
        $<BUILD_INTERFACE:${OF_DIRECTORY}/libs/openFrameworks/communication>
        $<BUILD_INTERFACE:${OF_DIRECTORY}/libs/openFrameworks/events>
        $<BUILD_INTERFACE:${OF_DIRECTORY}/libs/openFrameworks/gl>
        $<BUILD_INTERFACE:${OF_DIRECTORY}/libs/openFrameworks/graphics>
        $<BUILD_INTERFACE:${OF_DIRECTORY}/libs/openFrameworks/math>
        $<BUILD_INTERFACE:${OF_DIRECTORY}/libs/openFrameworks/sound>
        $<BUILD_INTERFACE:${OF_DIRECTORY}/libs/openFrameworks/types>
        $<BUILD_INTERFACE:${OF_DIRECTORY}/libs/openFrameworks/utils>
        $<BUILD_INTERFACE:${OF_DIRECTORY}/libs/openFrameworks/video>
        $<INSTALL_INTERFACE:include/openFrameworks>
        $<INSTALL_INTERFACE:include/openFrameworks/3d>
        $<INSTALL_INTERFACE:include/openFrameworks/app>
        $<INSTALL_INTERFACE:include/openFrameworks/communication>
        $<INSTALL_INTERFACE:include/openFrameworks/events>
        $<INSTALL_INTERFACE:include/openFrameworks/gl>
        $<INSTALL_INTERFACE:include/openFrameworks/graphics>
        $<INSTALL_INTERFACE:include/openFrameworks/math>
        $<INSTALL_INTERFACE:include/openFrameworks/sound>
        $<INSTALL_INTERFACE:include/openFrameworks/types>
        $<INSTALL_INTERFACE:include/openFrameworks/utils>
        $<INSTALL_INTERFACE:include/openFrameworks/video>
)

# Add utf8cpp subdirectory to include path manually
# The package installs to utf8cpp/ but OF expects it at root
if (TARGET utf8cpp::utf8cpp)
    get_target_property(UTF8CPP_INCLUDE_DIRS utf8cpp::utf8cpp INTERFACE_INCLUDE_DIRECTORIES)
    if (UTF8CPP_INCLUDE_DIRS)
        foreach (dir ${UTF8CPP_INCLUDE_DIRS})
            if (EXISTS "${dir}/utf8cpp")
                target_include_directories(openframeworks PUBLIC ${dir}/utf8cpp)
            endif ()
        endforeach ()
    endif ()
endif ()

# Generate config header with shader paths
configure_file(
        ${CMAKE_CURRENT_LIST_DIR}/cmake/ofConfig.h.in
        ${CMAKE_CURRENT_BINARY_DIR}/ofConfig.h
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/ofConfig.h
        DESTINATION include/openFrameworks
)

#target_include_directories(of_static PUBLIC
#        $<BUILD_INTERFACE:${OF_DIRECTORY}/libs/openFrameworks>
#        $<INSTALL_INTERFACE:include/openframeworks>
#)
# --------------------------------------------------
# Libraries
# --------------------------------------------------

if (OF_TARGET_MACOS)
    #    foreach (ITEM ${OF_LIB_NAMES})
    #        set(XCF_PATH "${OF_DIRECTORY}/libs/${ITEM}/lib/macos/${ITEM}.xcframework")
    #        # Some libs are include-only, so check if the xcframework exists
    #        if (EXISTS ${XCF_PATH})
    #            target_link_libraries(of_static PUBLIC ${XCF_PATH})
    #        endif ()
    #    endforeach ()

    find_library(accelerate_lib Accelerate)
    find_library(iokit_lib IOKit)
#    find_library(agl_lib AGL)
    find_library(applicationservices_lib ApplicationServices)
    find_library(audiotoolbox_lib AudioToolbox)
    find_library(coreaudio_lib CoreAudio)
    find_library(corefoundation_lib CoreFoundation)
    find_library(coreservices_lib CoreServices)
    find_library(opengl_lib OpenGL)
    find_library(corevideo_lib CoreVideo)
    find_library(qtkit_lib QTKit)
    find_library(cocoa_lib Cocoa)
    find_library(coremedia_lib CoreMedia)
    find_library(avfoundation_lib AVFoundation)
    find_library(quartzcore_lib QuartzCore)
    find_library(appkit_lib AppKit)
    find_library(security_lib Security)
    find_library(ldap_lib LDAP)
    find_library(sys_conf SystemConfiguration)

    set(OF_FRAMEWORKS
            ${accelerate_lib}
            ${iokit_lib}
            ${agl_lib}
            ${applicationservices_lib}
            ${audiotoolbox_lib}
            ${coreaudio_lib}
            ${corefoundation_lib}
            ${coreservices_lib}
            ${opengl_lib}
            ${quicktime_lib}
            ${corevideo_lib}
            ${qtkit_lib}
            ${cocoa_lib}
            ${coremedia_lib}
            ${avfoundation_lib}
            ${quartzcore_lib}
            ${appkit_lib}
            ${security_lib}
            ${ldap_lib}
            ${sys_conf}
    )

    target_link_libraries(of_static PUBLIC ${OF_FRAMEWORKS})

elseif (OF_TARGET_VS)
    find_package(videoinput CONFIG REQUIRED)
    target_link_libraries(of_static PUBLIC
            videoinput::videoinput
            opengl32 gdi32 winmm dxguid ole32 oleaut32
            uuid strmiids wsock32 ws2_32
            mfplat mfreadwrite mfuuid
    )

    #    target_link_libraries(of_static PUBLIC ${OF_WIN_SYSTEM_LIBS})
endif ()

#target_link_libraries(of_static PUBLIC ${OF_ADDON_FRAMEWORKS} ${OF_CORE_LIBS} ${OF_CORE_FRAMEWORKS})
# target_link_libraries(of_shared ${OF_ADDON_FRAMEWORKS} ${OF_CORE_LIBS} ${OF_CORE_FRAMEWORKS} )

# -------------------------------- Properties --------------------------------


# --------------------------------------------------
# Compilation options
# --------------------------------------------------
if (OF_TARGET_MACOS)
    set_source_files_properties(${OF_SRC} PROPERTIES
            COMPILE_FLAGS "-fobjc-arc")
    target_compile_options(of_static PUBLIC
            $<$<CONFIG:Debug>:-O0>
            $<$<CONFIG:Release>:-O3>
            $<$<COMPILE_LANGUAGE:CXX>:-std=c++20 -stdlib=libc++ -fobjc-arc -x objective-c++>
            $<$<COMPILE_LANGUAGE:C>:-x objective-c>
            -Wno-deprecated-declarations
    )
    target_compile_definitions(of_static PUBLIC __MACOSX_CORE__)

elseif (OF_TARGET_VS)
    message(STATUS "Using MSVC version: ${MSVC_VERSION}")

    target_compile_definitions(of_static PUBLIC
#            GLEW_STATIC
            NOMINMAX
            _USE_MATH_DEFINES
            WIN32_LEAN_AND_MEAN
            UNICODE _UNICODE
            OF_SOUND_PLAYER_MEDIA_FOUNDATION
            _HAS_STREAM_INSERTION_OPERATORS_DELETED_IN_CXX20
            GLM_FORCE_CTOR_INIT
#            GLM_ENABLE_EXPERIMENTAL
            CAIRO_WIN32_STATIC_BUILD
            FREEIMAGE_LIB
    )

    target_compile_options(of_static PUBLIC
            ##            $<$<CONFIG:Debug>:/D _DEBUG /TP /Gy /Gs- /Od /ZI /MDd>
            ##            $<$<CONFIG:Release>:/O2 /W1 /MD>
            ##            $<$<COMPILE_LANGUAGE:CXX>:/std:c++20>
            ##            $<$<COMPILE_LANGUAGE:C>:/std:c17>
            /Zc:__cplusplus
            /Zc:wchar_t
            #            #            /WX- /Zc:forScope /Gd /FC /EHsc /nologo /Zc:inline /fp:precise
    )

endif ()





