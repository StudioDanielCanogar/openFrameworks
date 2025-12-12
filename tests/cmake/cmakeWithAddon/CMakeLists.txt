cmake_minimum_required(VERSION 3.28)

# Set the location of the openFrameworks directory:
# Make it absolute:
get_filename_component(OF_DIRECTORY ../../../ REALPATH)
message("OF DIRECTORY: ${OF_DIRECTORY}")

# Include the main CMakeLists, this adds OF as a target and includes the helper macros
include(${OF_DIRECTORY}/cmake/of_macros.cmake)

# Declare your project
project("CMakeAddon")

# This adds the of source to the build, but excludes it from compilation.
# Very useful for debugging.
add_subdirectory(${OF_DIRECTORY} "of" EXCLUDE_FROM_ALL)

# Add the source files that you want to compile with your project
file(GLOB_RECURSE SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")

# This creates your app! Give it a name and pass it the list of sources
ofApp(${PROJECT_NAME} "${SOURCES}")

# This function will include an addon. Please note that some addons may not work at the moment.
ofIncludeAddon(ofxOpenCv)

#that's it!
