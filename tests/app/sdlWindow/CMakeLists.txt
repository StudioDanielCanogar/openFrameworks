cmake_minimum_required(VERSION 3.28)

# Set the location of the openFrameworks directory:
# Make it absolute:
get_filename_component(OF_DIRECTORY ../../../../openFrameworks REALPATH)
message("OF DIRECTORY: ${OF_DIRECTORY}")

# Include the main CMakeLists, this adds OF as a target and includes the helper macros.
# This needs to be included BEFORE the project() declaration.
include(${OF_DIRECTORY}/cmake/of_macros.cmake)

project(sdlWindow)

# Collect sources from src folder
file(GLOB_RECURSE APP_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)

# This creates your app! Give it a name and pass it the list of sources
ofApp(${PROJECT_NAME} "${APP_SOURCES}")
target_compile_definitions(${PROJECT_NAME} PRIVATE TARGET_SDL_WINDOW)

# Include src directory
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/)

#add_subdirectory(${OF_DIRECTORY}/libs/openFrameworks "of_src" EXCLUDE_FROM_ALL)

