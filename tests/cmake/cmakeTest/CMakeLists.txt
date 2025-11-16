cmake_minimum_required(VERSION 3.25)
project(myFirstApp LANGUAGES C CXX)

# Use C++20 to match openFrameworks
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

# Determine build directory based on CMAKE_BUILD_TYPE
if(CMAKE_BUILD_TYPE MATCHES "Debug")
    set(OF_BUILD_DIR "cmake-build-debug")
else()
    set(OF_BUILD_DIR "cmake-build-release")
endif()

# Set the path to openFrameworks build directory
set(openframeworks_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../${OF_BUILD_DIR}")
message(STATUS "Looking for openFrameworks in: ${openframeworks_DIR}")

# CRITICAL: Find CURL before finding openFrameworks
# This ensures CURL::libcurl_static target exists when openframeworks-targets.cmake loads
find_package(CURL CONFIG REQUIRED)

# Find openFrameworks
find_package(openframeworks REQUIRED PATHS ${openframeworks_DIR} NO_DEFAULT_PATH)

# Collect sources from src folder
file(GLOB APP_SOURCES "src/*.cpp")
file(GLOB APP_HEADERS "src/*.h")

# Create executable
add_executable(${PROJECT_NAME} ${APP_SOURCES} ${APP_HEADERS})

# Link openFrameworks
target_link_libraries(${PROJECT_NAME} PRIVATE 
    openframeworks::openframeworks
)

# Include src directory
target_include_directories(${PROJECT_NAME} PRIVATE src)

# Output to bin
set_target_properties(${PROJECT_NAME} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin"
        RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_CURRENT_SOURCE_DIR}/bin"
        RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_CURRENT_SOURCE_DIR}/bin"
        VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin"
)