cmake_minimum_required(VERSION 3.28)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")

# Set the location of the openFrameworks directory:
# Make it absolute:
get_filename_component(OF_DIRECTORY ../../../../openFrameworks REALPATH)
message("OF DIRECTORY: ${OF_DIRECTORY}")


project(cmakeTest)

# Include the main CMakeLists, this adds OF as a target and includes the helper macros
include(${OF_DIRECTORY}/cmake/of_macros.cmake)

# Collect sources from src folder
file(GLOB_RECURSE APP_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)


# This creates your app! Give it a name and pass it the list of sources
ofApp(${PROJECT_NAME} "${APP_SOURCES}")

# Include src directory
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/)


