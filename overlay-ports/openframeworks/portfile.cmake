#vcpkg_from_git(
#        OUT_SOURCE_PATH SOURCE_PATH
##        URL "https://github.com/StudioDanielCanogar/openFrameworks.git"
#        #        REF 6d9fb309d446addf2f433d5ec7262cd25daac438 FETCH_REF vcpkg
#        URL "file:///Users/cmendoza/developer/canogar/openFrameworks"
#        REF HEAD
#)
set(SOURCE_PATH "/Users/cmendoza/developer/canogar/openFrameworks")
# Configure
if(VCPKG_TARGET_IS_OSX)
    list(APPEND PLATFORM_FLAGS -DOF_TARGET_MACOS=ON)
elseif(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND PLATFORM_FLAGS -DOF_TARGET_VS=ON)
elseif(VCPKG_TARGET_IS_LINUX)
    list(APPEND PLATFORM_FLAGS -DOF_TARGET_LINUX=ON)
endif()

vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
#        PREFER_NINJA
        OPTIONS ${PLATFORM_FLAGS}
)

# Build + install
# Use the modern vcpkg_cmake_install function
vcpkg_cmake_install()



file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/openFrameworks/.idea")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")


# Fix up CMake config files location
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/openframeworks)

# Fix .pc files if needed
#vcpkg_fixup_pkgconfig()

# Copy config files to vcpkg-standard location
#message(STATUS "---------------------PACKAGES DIR: ${CMAKE_INSTALL_PREFIX}")

#file(INSTALL
#        "${CURRENT_PACKAGES_DIR}"
#        DESTINATION "${CURRENT_PACKAGES_DIR}/share/openframeworks"
#        FILES_MATCHING PATTERN "*.cmake"
#)

# Install license
#file(INSTALL "${SOURCE_PATH}/LICENSE"
#        DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
#)