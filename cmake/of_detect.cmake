
function(ensure_vcpkg_json)
    set(VCPKG_JSON_PATH "${CMAKE_SOURCE_DIR}/vcpkg.json")

    if (NOT EXISTS "${VCPKG_JSON_PATH}")
        message(STATUS "vcpkg.json not found — creating one...")

        file(WRITE "${VCPKG_JSON_PATH}"
                "{\n"
                "  \"dependencies\": [\n"
                "    \"openframeworks\"\n"
                "  ]\n"
                "}\n"
        )

        message(STATUS "Created ${VCPKG_JSON_PATH}")
    else ()
        message(STATUS "vcpkg.json already exists — skipping creation")
    endif ()
endfunction()

function(ensureAppRC)
    if (NOT OF_TARGET_VS)
        message(STATUS "Not a Windows target — skipping app.rc setup")
        return()
    endif ()
    set(APP_RC_PATH "${CMAKE_SOURCE_DIR}/app.rc")
    if (NOT EXISTS "${APP_RC_PATH}")
        message(STATUS "app.rc not found — creating one...")

        file(WRITE "${APP_RC_PATH}" [=[
#include <windows.h>

IDI_APP_ICON ICON "app_icon.ico"

VS_VERSION_INFO VERSIONINFO
 FILEVERSION 1,0,0,0
 PRODUCTVERSION 1,0,0,0
 FILEFLAGSMASK 0x3fL
 FILEFLAGS 0x0L
 FILEOS VOS__WINDOWS32
 FILETYPE VFT_APP
 FILESUBTYPE 0x0L
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
        BLOCK "040904B0"
        BEGIN
            VALUE "CompanyName", "Studio Daniel Canogar\0"
//            VALUE "FileDescription", "My Application\0"
//            VALUE "FileVersion", "1.0.0.0\0"
//           VALUE "ProductName", "MyApp\0"
//           VALUE "ProductVersion", "1.0.0.0\0"
        END
    END
END
]=]
        )

        message(STATUS "Created ${APP_RC_PATH}")
    else ()
        message(STATUS "app.rc already exists — skipping creation")
    endif ()

    message(STATUS "${CMAKE_SOURCE_DIR}/app.ico")
    if (EXISTS ${CMAKE_SOURCE_DIR}/app.ico)
        message(STATUS "app.ico already exists — skipping copy")
    else ()
        message(STATUS "app.ico not found — copying default icon...")
        configure_file(
                "${OF_DIRECTORY}/libs/openFrameworksCompiled/project/vs/icon.ico"
                "${CMAKE_SOURCE_DIR}/app.ico"
                COPYONLY
        )
    endif ()
endfunction()


function(ofDetectTarget)

    set(VCPKG_JSON_PATH "${CMAKE_SOURCE_DIR}/vcpkg.json")

    if (NOT EXISTS "${VCPKG_JSON_PATH}")
        message(STATUS "vcpkg.json not found — creating one...")

        file(WRITE "${VCPKG_JSON_PATH}"
                "{\n"
                "  \"dependencies\": [\n"
                "    \"openframeworks\"\n"
                "  ]\n"
                "}\n"
        )

        message(STATUS "Created ${VCPKG_JSON_PATH}")
    else ()
        message(STATUS "vcpkg.json already exists — skipping creation")
    endif ()


    set(supportedTargets
            CATOS
            EMSCRIPTEN
            IOS
            LINUX
            LINUX_ARM_V6
            LINUX_ARM_V7
            MACOS
            MSYS2
            OSX
            TVOS
            VS
            WATCHOS
            VISIONOS
            XROS
    )

    # If TARGET_OS was passed in
    if (DEFINED OF_TARGET_OS)
        string(TOUPPER "${OF_TARGET_OS}" TARGET_OS_UPPER)

        #         Remove the "OF_TARGET_" prefix if user included it
        string(REGEX REPLACE "^OF_TARGET_" "" TARGET_NAME "${TARGET_OS_UPPER}")

        list(FIND supportedTargets "${TARGET_NAME}" idx)
        if (idx EQUAL -1)
            message(FATAL_ERROR "Unknown TARGET_OS: ${TARGET_OS}. Must be one of: ${knownTargets}")
        endif ()
        #         Enable the requested target variable
        set("OF_TARGET_${TARGET_NAME}" ON CACHE BOOL "Enable ${TARGET_NAME} target" FORCE)
        message(STATUS "Target OS set explicitly: OF_TARGET_${TARGET_NAME}=ON")
    else ()
        # Auto-detection logic goes here
        message(STATUS "TARGET_OS not set, will auto-detect...")
        foreach (t IN LISTS knownTargets)
            set("OF_TARGET_${TARGET_NAME}" OFF CACHE BOOL "Enable ${TARGET_NAME} target" FORCE)
        endforeach ()
        #        message(STATUS ${CMAKE_SYSTEM_PROCESSOR})
        if (APPLE)
            message(STATUS "Target macOS")
            set(OF_TARGET_MACOS ON CACHE BOOL "Enable target" FORCE)
            set(OF_TARGET_OSX ON CACHE BOOL "Enable target" FORCE)
        elseif (LINUX)
            message(STATUS "Target Linux")
            set(OF_TARGET_LINUX ON CACHE BOOL "Enable target" FORCE)
        elseif (WIN32)
            message(STATUS "Target Windows")
            set(OF_TARGET_VS ON CACHE BOOL "Enable target" FORCE)
            set(OF_TARGET_WINDOWS ON CACHE BOOL "Enable target" FORCE)
        else ()
            message(WARNING "Could not determine target platform")
            return()
        endif ()
    endif ()

    ensureAppRC()

    set(VCPKG_ROOT ${OF_DIRECTORY}/thirdParty/vcpkg CACHE STRING "" FORCE)
    set(CMAKE_TOOLCHAIN_FILE "${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" CACHE STRING "")
    set(VCPKG_OVERLAY_PORTS ${OF_DIRECTORY}/overlay-ports/ CACHE STRING "")
    #    message(STATUS "------------${VCPKG_OVERLAY_PORTS}")
    # Auto-detect and set static triplet if not specified
    if (NOT DEFINED VCPKG_TARGET_TRIPLET)
        if (WIN32)
            set(VCPKG_CRT_LINKAGE "dynamic")
            set(VCPKG_LIBRARY_LINKAGE "static")
            set(VCPKG_TARGET_TRIPLET "x64-windows-static-md" CACHE STRING "")
            set(VCPKG_PLATFORM_TOOLSET "v143" CACHE STRING "" FORCE)
        elseif (APPLE)
            #                if (ARCH MATCHES "arm64|aarch64")
            #                    set(VCPKG_TARGET_TRIPLET "arm64-osx" CACHE STRING "")
            #                else ()
            #                    set(VCPKG_TARGET_TRIPLET "x64-osx" CACHE STRING "")
            #                endif ()
        else ()
            #            set(VCPKG_TARGET_TRIPLET "x64-linux" CACHE STRING "")
        endif ()
    endif ()
endfunction()

function(ofDetectArch)
    #    set (supportedArchs
    #            X86_64
    #            ARM64
    #            ARMEC
    #            ARMV6
    #            ARMV7
    #            MEMORY64
    #            x86_64_SIMULATOR
    #    )
    #
endfunction()