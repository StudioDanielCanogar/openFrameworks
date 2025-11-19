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

# Install headers to main include directory only
file(GLOB HEADERS "${VIDEOINPUT_SRC}/*.h")
file(INSTALL ${HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include/videoinput")

# Create our own CMakeLists.txt (ignore the existing one)
file(WRITE "${VIDEOINPUT_SRC}/CMakeLists.txt" "
cmake_minimum_required(VERSION 3.10)
project(videoinput)

add_library(videoinput STATIC videoInput.cpp)

target_link_libraries(videoinput PUBLIC
    strmiids
    ole32
    oleaut32
)

install(TARGETS videoinput
    EXPORT videoinputTargets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

# Install export targets
install(EXPORT videoinputTargets
        FILE videoinputTargets.cmake
        NAMESPACE videoinput::
        DESTINATION lib/cmake/videoinput
)
")

vcpkg_cmake_configure(SOURCE_PATH "${VIDEOINPUT_SRC}")
vcpkg_cmake_install()


# Remove any debug include directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Create the config file manually - this gives us full control
file(WRITE "${CURRENT_PACKAGES_DIR}/share/videoinput/videoinput-config.cmake"
        "# videoinput config file

if(TARGET videoinput::videoinput)
    return()
endif()

get_filename_component(_videoinput_root \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)
get_filename_component(_videoinput_root \"\${_videoinput_root}\" PATH)
get_filename_component(_videoinput_root \"\${_videoinput_root}\" PATH)

add_library(videoinput::videoinput STATIC IMPORTED)

set_target_properties(videoinput::videoinput PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES \"\${_videoinput_root}/include/videoinput\"
  INTERFACE_LINK_LIBRARIES \"strmiids;ole32;oleaut32\"
)

# Set the library location for debug
if(EXISTS \"\${_videoinput_root}/debug/lib/videoinput.lib\")
  set_property(TARGET videoinput::videoinput APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
  set_target_properties(videoinput::videoinput PROPERTIES
    IMPORTED_LOCATION_DEBUG \"\${_videoinput_root}/debug/lib/videoinput.lib\"
  )
endif()

# Set the library location for release
if(EXISTS \"\${_videoinput_root}/lib/videoinput.lib\")
  set_property(TARGET videoinput::videoinput APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
  set_target_properties(videoinput::videoinput PROPERTIES
    IMPORTED_LOCATION_RELEASE \"\${_videoinput_root}/lib/videoinput.lib\"
    IMPORTED_LOCATION \"\${_videoinput_root}/lib/videoinput.lib\"
  )
endif()

set(videoinput_FOUND TRUE)
")


# Copyright
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "Copyright (c) Theodore Watson - https://github.com/ofTheo/videoInput")