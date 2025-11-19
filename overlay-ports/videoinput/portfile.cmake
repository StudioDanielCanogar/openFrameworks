vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO ofTheo/videoInput
        REF 2014-Stable
        SHA512 ab8ff0576a3287fb5cf4742839b6d5865e23e608231ba8eab714262b5e32dace5a3b1f605c1d1d3600949b5d1f772a1a7dc86db7f60e5f517b514705f49f1335
        HEAD_REF master
)

# Source files are in videoInputSrcAndDemos/libs/videoInput
set(VIDEOINPUT_SRC "${SOURCE_PATH}/videoInputSrcAndDemos/libs/videoInput")

# Create our own CMakeLists.txt (ignore the existing one)
file(WRITE "${VIDEOINPUT_SRC}/CMakeLists.txt" [=[
cmake_minimum_required(VERSION 3.10)
project(videoinput)

add_library(videoinput STATIC videoInput.cpp)

target_include_directories(videoinput PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include/videoinput>
)

target_link_libraries(videoinput PUBLIC
    strmiids
    ole32
    oleaut32
)

# Install library
install(TARGETS videoinput
    EXPORT videoinputTargets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

# Install headers
file(GLOB HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
install(FILES ${HEADERS} DESTINATION include/videoinput)

# Install export targets
install(EXPORT videoinputTargets
    FILE videoinputTargets.cmake
    NAMESPACE videoinput::
    DESTINATION lib/cmake/videoinput
)

# Generate and install config file
include(CMakePackageConfigHelpers)

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/videoinput-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/videoinput-config.cmake
    INSTALL_DESTINATION lib/cmake/videoinput
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/videoinput-config.cmake
    DESTINATION lib/cmake/videoinput
)
]=])

# Create the config.cmake.in file
file(WRITE "${VIDEOINPUT_SRC}/videoinput-config.cmake.in" "
@PACKAGE_INIT@

include(\"\${CMAKE_CURRENT_LIST_DIR}/videoinputTargets.cmake\")

check_required_components(videoinput)
")

vcpkg_cmake_configure(SOURCE_PATH "${VIDEOINPUT_SRC}")
vcpkg_cmake_install()

# Fix cmake config location
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/videoinput)

# Remove debug include directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install copyright
#vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/readme.txt")