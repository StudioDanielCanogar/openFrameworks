cmake_minimum_required(VERSION 3.28)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:>DLL")
set(CMAKE_CONFIGURATION_TYPES "RelWithDebInfo;Debug;Release;")


#if (CMAKE_CURRENT_LIST_DIR STREQUAL CMAKE_SOURCE_DIR)
project(openFrameworks)
#endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
set(OF_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

#set(VCPKG_ROOT ${OF_DIRECTORY}/thirdParty/vcpkg)
#set(CMAKE_TOOLCHAIN_FILE "${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
#message(STATUS "------------------------\n${CMAKE_TOOLCHAIN_FILE}")


include(of_macros)

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

# Export target for downstream apps
install(TARGETS of_static
        EXPORT openFrameworksTargets
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        RUNTIME DESTINATION bin
)

# Install openFrameworks headers
install(DIRECTORY libs/openFrameworks
        DESTINATION include
        FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp" PATTERN "*.inl"
)
find_package(PkgConfig REQUIRED)

find_package(fmt CONFIG REQUIRED)
find_package(unofficial-brotli CONFIG REQUIRED)

pkg_check_modules(CAIRO REQUIRED cairo)
add_library(Cairo::Cairo INTERFACE IMPORTED)
target_include_directories(Cairo::Cairo INTERFACE
        "${CAIRO_INCLUDEDIR}"
)
target_link_libraries(Cairo::Cairo INTERFACE
        ${CAIRO_LIBRARIES}
)

#target_include_directories(of_static PUBLIC ${cairo_INCLUDE_DIRS})

#target_include_directories(of_static PUBLIC ${cairo_INCLUDE_DIRS})
find_package(ZLIB REQUIRED)
find_package(PNG REQUIRED)
find_package(Freetype REQUIRED)

pkg_check_modules(PIXMAN REQUIRED pixman-1)
add_library(Pixman::Pixman INTERFACE IMPORTED)
target_include_directories(Pixman::Pixman INTERFACE
        "${PIXMAN_INCLUDEDIR}"
)
target_link_libraries(Pixman::Pixman INTERFACE
        ${PIXMAN_LIBRARIES}
)

find_package(OpenSSL REQUIRED)
find_package(CURL REQUIRED)
find_package(freeimage CONFIG REQUIRED)
find_package(GLEW REQUIRED)
find_package(glfw3 CONFIG REQUIRED)
find_package(glm CONFIG REQUIRED)
find_package(unofficial-libtess2 CONFIG REQUIRED)

pkg_check_modules(LIBUSB REQUIRED libusb-1.0)
add_library(libusb::libusb INTERFACE IMPORTED)
target_include_directories(libusb::libusb INTERFACE
        "${LIBUSB_INCLUDEDIR}"
)
target_link_libraries(libusb::libusb INTERFACE
        ${LIBUSB_LIBRARIES}
)

find_package(nlohmann_json CONFIG REQUIRED)
find_package(pugixml CONFIG REQUIRED)
find_package(RtAudio CONFIG REQUIRED)
find_package(uriparser CONFIG REQUIRED char wchar_t)
find_package(utf8cpp CONFIG REQUIRED)

## Propagate include dirs for pkg-config-only deps
#if (cairo_FOUND)
#    target_include_directories(of_static PUBLIC ${cairo_INCLUDE_DIRS})
#endif()
#if (libusb_FOUND)
#    target_include_directories(of_static PUBLIC ${libusb_INCLUDE_DIRS})
#endif()

# Optional: propagate other CFLAGS from pkg-config if needed
target_compile_options(of_static PUBLIC ${cairo_CFLAGS_OTHER} ${libusb_CFLAGS_OTHER})

target_link_libraries(of_static PUBLIC unofficial::brotli::brotlidec)
target_link_libraries(of_static PUBLIC unofficial::brotli::brotlienc)
target_link_libraries(of_static PUBLIC Cairo::Cairo)
target_link_libraries(of_static PUBLIC ZLIB::ZLIB)
target_link_libraries(of_static PUBLIC PNG::PNG)
target_link_libraries(of_static PUBLIC Freetype::Freetype)
target_link_libraries(of_static PUBLIC Pixman::Pixman)
target_link_libraries(of_static PUBLIC OpenSSL::SSL)
target_link_libraries(of_static PUBLIC OpenSSL::Crypto)
target_link_libraries(of_static PUBLIC CURL::libcurl_static)
target_link_libraries(of_static PUBLIC fmt::fmt)
target_link_libraries(of_static PUBLIC freeimage::FreeImage)
target_link_libraries(of_static PUBLIC GLEW::glew_s)
target_link_libraries(of_static PUBLIC glfw)
target_link_libraries(of_static PUBLIC glm::glm-header-only)
target_link_libraries(of_static PUBLIC unofficial::libtess2::libtess2)
target_link_libraries(of_static PUBLIC libusb::libusb)
target_link_libraries(of_static PUBLIC nlohmann_json::nlohmann_json)
target_link_libraries(of_static PUBLIC pugixml::static pugixml::pugixml)
target_link_libraries(of_static PUBLIC RtAudio::rtaudio)
target_link_libraries(of_static PUBLIC uriparser::uriparser)
target_link_libraries(of_static PUBLIC utf8::cpp utf8cpp::utf8cpp)



# Install 3rd-party headers
set(OF_LIB_NAMES
#        brotli
#        cairo
#        curl
#        fmt
#        FreeImage
#        freetype
#        glew
#        glfw
#        glm
#        json
#        libpng
#        libusb
#        openssl
#        pixman
#        pugixml
#        rtAudio
#        tess2
#        uriparser
#        utf8
#        zlib
)

if (OF_TARGET_VS)
    list(APPEND OF_LIB_NAMES videoInput)
endif ()

#foreach (item ${OF_LIB_NAMES})
#    #    message("ITEM:::::: ${item}")
#    install(DIRECTORY libs/${item}/include
#            DESTINATION include
#            FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp" PATTERN "*.inl")
#endforeach ()

#foreach (item ${OF_LIB_NAMES})
#    set(WIN_ARCH "x64") # hardcoded for now
#
#    if (OF_TARGET_VS)
#        install(DIRECTORY libs/${item}/lib/vs/${WIN_ARCH}/
#                DESTINATION lib
#                FILES_MATCHING PATTERN "*.lib")
#    elseif (OF_TARGET_MACOS)
#        install(DIRECTORY libs/${item}/lib/macos/
#                DESTINATION lib
#                FILES_MATCHING PATTERN "*.a" PATTERN "*.dylib")
#        set(XCF_PATH "${OF_DIRECTORY}/libs/${item}/lib/macos/${item}.xcframework")
#        if (EXISTS ${XCF_PATH})
#            install(DIRECTORY ${XCF_PATH} DESTINATION lib)
#        endif ()
#    elseif (OF_TARGET_LINUX)
#        install(DIRECTORY libs/${dir}/lib/linux/
#                DESTINATION lib
#                FILES_MATCHING PATTERN "*.a" PATTERN "*.so")
#    endif ()
#endforeach ()

add_custom_target(build_and_install
        COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target install
        DEPENDS of_static
)

# Export targets
install(EXPORT openFrameworksTargets
        FILE openFrameworksTargets.cmake
        NAMESPACE openFrameworks::
        DESTINATION lib/cmake/openFrameworks
)

# Generate the config and version files for find_package
configure_package_config_file(
        ${CMAKE_CURRENT_LIST_DIR}/cmake/openFrameworksConfig.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/openFrameworksConfig.cmake
        INSTALL_DESTINATION lib/cmake/openFrameworks
)

write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/openFrameworksConfigVersion.cmake
        VERSION 0.1.0
        COMPATIBILITY SameMajorVersion
)

install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/openFrameworksConfig.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/openFrameworksConfigVersion.cmake
        DESTINATION lib/cmake/openFrameworks
)

# These don't seem to work
set_target_properties(of_static PROPERTIES
        OUTPUT_NAME "openframeworksLib$<$<CONFIG:Debug>:_debug>"
        CXX_STANDARD 20
        CXX_STANDARD_REQUIRED ON
        C_STANDARD 17
        C_STANDARD_REQUIRED ON
)

add_custom_command(TARGET of_static POST_BUILD
        COMMAND ${CMAKE_COMMAND} --install ${CMAKE_BINARY_DIR}
        COMMENT "Installing openFrameworks after build"
)

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
target_include_directories(of_static PUBLIC
        $<BUILD_INTERFACE:${OF_HEADERS}>
        $<INSTALL_INTERFACE:include>
)
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
    find_library(agl_lib AGL)
    find_library(applicationservices_lib ApplicationServices)
    find_library(audiotoolbox_lib AudioToolbox)
    find_library(coreaudio_lib CoreAudio)
    find_library(corefoundation_lib CoreFoundation)
    find_library(coreservices_lib CoreServices)
    find_library(opengl_lib OpenGL)
    # find_library(quicktime_lib QuickTime)
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
    set(OF_LIB_DIRS)
    set(OF_LIB_FILES
            brotlicommon.lib
            brotlidec.lib
            brotlienc.lib
            libcairo.lib
            libcurl.lib
#            fmt.lib
            FreeImage$<$<CONFIG:Debug>:D>.lib
            #            FreeImage.lib
            freetype$<$<CONFIG:Debug>:d>.lib
            #            freetype.lib
            libglew32.lib
            glfw3.lib
            libpng.lib
            libcrypto.lib
            libssl.lib
            libpixman-1.lib
            pugixml$<$<CONFIG:Debug>:D>.lib
            #            pugixml.lib
            rtaudio$<$<CONFIG:Debug>:D>.lib
            #            rtaudio.lib
            tess2.lib
            uriparser.lib
            videoInput$<$<CONFIG:Debug>:D>.lib
            #            videoInput.lib
            zlib.lib
    )

    #        message(STATUS ${OF_LIB_FILES})
    set(WIN_ARCH "x64")
    list(APPEND OF_LIB_NAMES "videoInput")
    include_directories(${OF_DIRECTORY}/libs/videoInput/include)


    set(FOUND_LIBS)
    foreach (LIB ${OF_LIB_NAMES})
        set(LIB_DIR "${OF_DIRECTORY}/libs/${LIB}/lib/vs/${WIN_ARCH}")
        list(APPEND OF_LIB_DIRS ${LIB_DIR})
        target_link_directories(of_static
                PUBLIC
                $<BUILD_INTERFACE:${OF_DIRECTORY}/libs/${LIB}/lib/vs/${WIN_ARCH}>
                $<INSTALL_INTERFACE:lib>
        )
        #        message("$<INSTALL_INTERFACE:vs/lib/${LIB}")
    endforeach ()
    #    target_link_directories(of_static
    #            INTERFACE
    #            $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/libs/curl/lib/vs/x64>
    #            $<INSTALL_INTERFACE:lib>    # <-- tells consumers to use install tree
    #    )
    #    target_link_directories(of_static PUBLIC ${OF_LIB_DIRS})
    #    message("KAJSHKJHSKJ --- ${OF_LIB_FILES}")
    target_link_libraries(of_static PUBLIC ${OF_LIB_FILES})
    #
    #        message(STATUS "Searching for ${LIB} in ${LIB_DIR}")
    #
    #        find_library(found_lib_${LIB} NAMES ${LIB} PATHS ${LIB_DIR} NO_DEFAULT_PATH)
    #
    #        if (found_lib)
    #            message(STATUS "Found: ${found_lib_${LIB}}")
    #            list(APPEND FOUND_LIBS ${found_lib_${LIB}})
    #        else ()
    #            message(WARNING "Library ${LIB} not found in ${LIB_DIR}")
    #        endif ()


    #        set(LIB_DIR ${OF_DIRECTORY}/libs/${LIB}/lib/vs/${WIN_ARCH})
    #        file(GLOB LIB_FILES "${LIB_DIR}/*.lib")
    #        list(LENGTH LIB_FILES len)
    #        if (len GREATER 0)
    #            of_remove_debug_libs(LIB_FILES_NO_D "${LIB_FILES}")
    #            target_link_libraries(of_static PUBLIC ${LIB_FILES_NO_D})
    #        endif ()

    #    endforeach ()

    message(STATUS ${FOUND_LIBS})
    set(OF_WIN_SYSTEM_LIBS msimg32 OpenGL32 kernel32 setupapi Vfw32 comctl32 dsound user32 gdi32 winspool comdlg32 advapi32 shell32 ole32 oleaut32 uuid iphlpapi crypt32 Ws2_32 winmm odbc32 odbccp32 wldap32 mf mfplat mfuuid d3d11 mfreadwrite xaudio2 ucrt)
    target_link_libraries(of_static PUBLIC ${OF_WIN_SYSTEM_LIBS})
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
    target_compile_definitions(of_static PUBLIC
            WIN32 CURL_STATICLIB URI_STATIC_BUILD _HAS_STREAM_INSERTION_OPERATORS_DELETED_IN_CXX20 _CONSOLE POCO_STATIC CAIRO_WIN32_STATIC_BUILD DISABLE_SOME_FLOATING_POINT OF_NO_FMOD GLM_FORCE_CTOR_INIT GLM_ENABLE_EXPERIMENTAL _UNICODE UNICODE FREEIMAGE_LIB) # GLEW_STATIC
    target_compile_options(of_static PUBLIC
            $<$<CONFIG:Debug>:/D _DEBUG /TP /external:W3 /Gy /Gs- /Od /ZI>
            $<$<CONFIG:Release>:/O2 /W1>
            $<$<COMPILE_LANGUAGE:CXX>:/std:c++20>
            $<$<COMPILE_LANGUAGE:C>:/std:c17>
            /WX- /Zc:forScope /Gd /FC /EHsc /nologo /Zc:__cplusplus /Zc:inline /Zc:wchar_t /fp:precise)
#    target_link_options(of_static PUBLIC /MACHINE:X64 /NOLOGO)
endif ()





