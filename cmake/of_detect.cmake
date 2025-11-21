
function(ofDetectTarget)

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
            #        message(STATUS "Running on macOS")
            set(OF_TARGET_MACOS ON CACHE BOOL "Enable target" FORCE)
            set(OF_TARGET_OSX ON CACHE BOOL "Enable target" FORCE)
        elseif (LINUX)
            set(OF_TARGET_LINUX ON CACHE BOOL "Enable target" FORCE)
        elseif (WIN32)
            set(OF_TARGET_VS ON CACHE BOOL "Enable target" FORCE)
            set(OF_TARGET_WINDOWS ON CACHE BOOL "Enable target" FORCE)
        else ()
            message(WARNING "Could not determine target platform")
            return()
        endif ()

    endif ()

    if (DEFINED VCPKG_ROOT)
        # Auto-detect and set static triplet if not specified
        if (NOT DEFINED VCPKG_TARGET_TRIPLET)
            if (WIN32)
                set(VCPKG_TARGET_TRIPLET "x64-windows-static-md" CACHE STRING "")
            elseif (APPLE)
                if (CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "arm64|aarch64")
                    set(VCPKG_TARGET_TRIPLET "arm64-osx" CACHE STRING "")
                else ()
                    set(VCPKG_TARGET_TRIPLET "x64-osx" CACHE STRING "")
                endif ()
            else ()
                set(VCPKG_TARGET_TRIPLET "x64-linux" CACHE STRING "")
            endif ()
            message(STATUS "Auto-detected vcpkg triplet: ${VCPKG_TARGET_TRIPLET}")
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