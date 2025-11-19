include_guard(GLOBAL)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")
include(of_detect)


#set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
if (CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo" OR
        CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
    set(_CONFIG "Release")
else ()
    set(_CONFIG "${CMAKE_BUILD_TYPE}")
endif ()

function(ofIncludeAddon addonName)
    function(find_addon_include_dirs ADDON_PATH OUT_INCLUDE_DIRS)
        set(INCLUDE_DIRS "")
        # Check if the 'libs' directory exists
        set(LIBS_PATH "${ADDON_PATH}/libs")
        if (NOT EXISTS ${LIBS_PATH})
            #        message(WARNING "No 'libs' directory found in ${ADDON_PATH}")
            set(${OUT_INCLUDE_DIRS} "" PARENT_SCOPE)
            return()
        endif ()

        # Loop through directories inside 'libs'
        file(GLOB LIB_DIRS LIST_DIRECTORIES true "${LIBS_PATH}/*")
        foreach (LIB_DIR ${LIB_DIRS})
            if (IS_DIRECTORY ${LIB_DIR})
                set(INCLUDE_PATH "${LIB_DIR}/include")

                # If 'include' directory exists, add it, otherwise add LIB_DIR itself
                if (EXISTS ${INCLUDE_PATH})
                    list(APPEND INCLUDE_DIRS ${INCLUDE_PATH})
                else ()
                    list(APPEND INCLUDE_DIRS ${LIB_DIR})
                endif ()
            endif ()
        endforeach ()

        # Return the list of include directories
        set(${OUT_INCLUDE_DIRS} "${INCLUDE_DIRS}" PARENT_SCOPE)
    endfunction()

    # Attempts to load addons that do not have cmake files. Will work with basic addons that have a src directory.
    # If there are libs that have sources, those will be compiled. It will also try to add static libs via ofAddGenericLib
    # that may be in the addon's libs folder. If that fails, you can import headers and libraries in your app's
    # CMakeLists.txt.
    function(of_load_generic_addon addonPath addonName)
        set(PATH_SRC ${addonPath}/src)
        set(PATH_LIBS ${addonPath}/libs)
        #        message(${addonPath})
        set(addonSrc)

        file(GLOB_RECURSE addonSrc
                "${PATH_SRC}/*.cpp"
                "${PATH_SRC}/*.cc"
                "${PATH_SRC}/*.c"
                "${PATH_SRC}/*.m"
                "${PATH_SRC}/*.mm"
        )

        #    set(libs_subdirs)
        ofGetSubdirNames(libs_subdirs ${PATH_LIBS})
        list(LENGTH addonSrc list_length)
        if (list_length EQUAL 0)
            #            message("List is empty")
        else ()
            ### So creating a separate lib for each addon currently poses problems, so I am
            ### disabling this. Maybe per-addon compile flags could help.
            ### Instead, we are adding the addon sources to the ofApp build (which is the way that OF does it)
            #            message("Addon ${addonName}")
            #            ofPrintList(addonSrc)
            #            add_library(${addonName} STATIC ${addonSrc})
            #            target_link_libraries(${OF_APP_NAME} PRIVATE ${addonName})
            #            add_dependencies(${OF_APP_NAME} ${addonName})
            target_sources(${OF_APP_NAME} PRIVATE ${addonSrc})
        endif ()

        foreach (item ${libs_subdirs})
            ofAddGenericLib(${PATH_LIBS}/${item} ${OF_APP_NAME})
        endforeach ()

        ofFindHeaderDirectories(HEADERS_SOURCE ${PATH_SRC})
        ofFindHeaderDirectories(HEADERS_LIBS ${PATH_LIBS})
        #        message(STATUS ${HEADERS_SOURCE})
        #        message(STATUS "---")
        #        message(STATUS ${HEADERS_LIB})
        include_directories(${PATH_SRC})
        #        find_addon_include_dirs(${ADDON_PATH} ADDON_INCLUDE_DIRS)
        #        message(STATUS "Found include directories: ${ADDON_INCLUDE_DIRS}")
        #        include_directories(${ADDON_INCLUDE_DIRS})
    endfunction()

    set(globalAddonPath "${OF_DIRECTORY}/addons/${addonName}")
    set(localAddonPath "${CMAKE_CURRENT_SOURCE_DIR}/${addonName}")

    # Look for a local addon first
    if (EXISTS ${localAddonPath})
        #        message(STATUS "Activating local addon from: ${localAddonPath}")
        if (EXISTS ${localAddonPath}/addon_config.cmake)
            message(STATUS "Activating local addon ${addonName} with addon_config.cmake")
            include(${localAddonPath}/addon_config.cmake)
        else ()
            message(STATUS "Activating local addon ${addonName} via generic function. The generic function makes assumptions about the addon's file structure and is not guaranteed to work in all cases.")
            of_load_generic_addon(${localAddonPath} ${addonName})
        endif ()
        # Then look in the global addons
    elseif (EXISTS ${globalAddonPath})
        if (EXISTS ${globalAddonPath}/addon_config.cmake)
            message(STATUS "Activating global addon ${addonName} with addon_config.cmake")
            include(${globalAddonPath}/addon_config.cmake)
        else ()
            message(STATUS "Activating ${addonName} via generic function. The generic function makes assumptions about the addon's file structure and is not guaranteed to work in all cases.")
            of_load_generic_addon(${globalAddonPath} ${addonName})
        endif ()
    else ()
        message(STATUS "Addon ${addonName} not found.")
    endif ()
endfunction()


# Adds a library to the current OF_APP via a generic template.
# The function assumes that the library is in the format:
# libName
#  |___ include
#  |___ lib
#  |___ src
# It will link all lib files it finds in the /lib directory.
function(ofAddGenericLib path target)
    if (EXISTS ${path}/include)
        include_directories(${path}/include)
    endif ()
    if (EXISTS ${path}/lib)
        #        message(${path}/lib)
        if (OF_TARGET_MACOS)
            file(GLOB foundLibs
                    "${path}/lib/macos/*.a"
                    "${path}/lib/macos/*.*framework"
                    "${path}/lib/osx/*.a"
                    "${path}/lib/osx/*.*framework"
            )
            message(STATUS ${foundLibs})
            target_link_libraries(${target} PRIVATE ${foundLibs})
            foreach (lib ${foundLibs})
                get_filename_component(ext ${lib} LAST_EXT)
                #                message(WARNING ${ext})
                if (${ext} STREQUAL ".framework" OR ${ext} STREQUAL ".xcframework")
                    #                    message(WARNING "eyyyopooo ${lib}/Headers")
                    target_include_directories(${target} PRIVATE "${lib}/Headers")
                endif ()
            endforeach ()
            #            target_link_directories(${target} PRIVATE "${path}/lib/macos/")
            #            target_link_directories(${target} PRIVATE "${path}/lib/osx/")
        elseif (OF_TARGET_VS)
            if (CMAKE_BUILD_TYPE MATCHES Debug)
                file(GLOB foundLibs
                        "${path}/lib/vs/x64/Debug/*.lib"
                )
            else ()
                file(GLOB foundLibs
                        "${path}/lib/vs/x64/Release/*.lib"
                )
            endif ()
            #            message("LIBS:")
            #            ofPrintList(foundLibs)
            #            message("TARGET: ${target}")
            target_link_libraries(${target} PRIVATE ${foundLibs})

        endif ()
    endif ()
    if (EXISTS ${path}/src)
        include_directories(${path}/src)
        file(GLOB_RECURSE libSources
                "${path}/src/*.cpp"
                "${path}/src/*.cc"
                "${path}/src/*.c"
                "${path}/src/*.m"
                "${path}/src/*.mm"
        )
        target_sources(${target} PUBLIC ${libSources})
    endif ()
endfunction()


# TODO Find also .hpp files
# ---- Find all include directories
function(ofFindHeaderDirectories return_list PATH)
    FILE(GLOB_RECURSE new_list ${PATH}/*.h)
    SET(dir_list "")
    FOREACH (file_path ${new_list})
        GET_FILENAME_COMPONENT(dir_path ${file_path} PATH)
        SET(dir_list ${dir_list} ${dir_path})
    ENDFOREACH ()
    LIST(REMOVE_DUPLICATES dir_list)
    SET(${return_list} ${dir_list})
endfunction(ofFindHeaderDirectories)

function(of_add_xcframework_lib TARGET LIB_DIR_NAME)
    # Pick the right slice depending on platform
    set(XCF_PATH "${OF_DIRECTORY}/libs/${LIB_DIR_NAME}/lib/macos/${LIB_DIR_NAME}.xcframework")
    if (CMAKE_SYSTEM_NAME STREQUAL "iOS")
        if (CMAKE_OSX_ARCHITECTURES MATCHES "x86_64|arm64" AND CMAKE_OSX_SYSROOT MATCHES ".*Simulator")
            # iOS Simulator
            set(LIB_DIR "${XCF_PATH}/ios-arm64_x86_64-simulator")
        else ()
            # iOS Device
            set(LIB_DIR "${XCF_PATH}/ios-arm64")
        endif ()
    elseif (CMAKE_SYSTEM_NAME STREQUAL "Darwin")
        # macOS
        set(LIB_DIR "${XCF_PATH}/macos-arm64_x86_64")
    endif ()

    file(GLOB LIB_FILES "${LIB_DIR}/*.a")

    message(VERBOSE "Adding lib: ${LIB_FILES}")

    target_link_libraries(${TARGET} PUBLIC ${LIB_FILES})

    #   if (EXISTS "${LIB_DIR}/${LIB_NAME}.a")
    #       set(LIB_PATH "${LIB_DIR}/${LIB_NAME}.a")
    #   else ()
    #       set(LIB_PATH "${LIB_DIR}/lib${LIB_NAME}.a")
    #   endif ()
    #
    #   if (EXISTS ${LIB_PATH})
    #       target_link_libraries(${TARGET} PUBLIC ${LIB_PATH})
    #   else ()
    #       message(FATAL_ERROR "Could not find library ${LIB_NAME} in ${LIB_PATH}")
    #   endif ()

endfunction(of_add_xcframework_lib)

set(OF_APP_NAME)
set(OF_MACOS_BUNDLE_ID "com.example.one")

macro(ofApp APP_NAME SOURCE_FILES)

    # This seems to be the only thing that sets the c++ standard...
    set(CMAKE_CXX_STANDARD 20)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_C_STANDARD 17)
    set(CMAKE_C_STANDARD_REQUIRED ON)

    set(OF_APP_NAME ${APP_NAME})
    set(OUTPUT_APP_NAME ${APP_NAME})
    if (CMAKE_BUILD_TYPE MATCHES Debug)
        set(OUTPUT_APP_NAME "${APP_NAME}_debug")
    endif ()

    set(ofIncludeDir "${OF_INSTALL_PREFIX}/include/openFrameworks")
    file(GLOB children RELATIVE "${ofIncludeDir}" "${ofIncludeDir}/*/")
    include_directories(${ofIncludeDir})
    include_directories(${OF_INSTALL_PREFIX}/include)
    ofGetSubdirNames(subDirs ${ofIncludeDir})
    ofPrintList(subDirs)
    foreach (item ${subDirs})
        include_directories("${ofIncludeDir}/${item}")
    endforeach ()
    if (OF_TARGET_MACOS)
        set(PLIST_TEMPLATE "${OF_DIRECTORY}/cmake/MacOSXBundleInfo.plist.in")
        set(PLIST_OUT "${CMAKE_BINARY_DIR}/MacOSXBundleInfo.plist")

        configure_file(${PLIST_TEMPLATE} ${PLIST_OUT})
        add_executable(${APP_NAME} MACOSX_BUNDLE "${SOURCE_FILES}")
        set_target_properties(${APP_NAME} PROPERTIES
                MACOSX_BUNDLE TRUE
                MACOSX_BUNDLE_INFO_PLIST ${PLIST_OUT}
                CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ""
                CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO"
                RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin
                OUTPUT_NAME ${OUTPUT_APP_NAME}
                #                MACOSX_BUNDLE_GUI_IDENTIFIER ${MACOS_BUNDLE_ID}
        )

        target_compile_options(${APP_NAME} PUBLIC
                $<$<CONFIG:Debug>:-O0>
                $<$<CONFIG:Release>:-O3>
                -fobjc-arc
                $<$<COMPILE_LANGUAGE:CXX>:-std=c++20 -stdlib=libc++ -fobjc-arc -x objective-c++>
                $<$<COMPILE_LANGUAGE:C>:-x objective-c>
                -Wno-deprecated-declarations
        )
        target_compile_definitions(${APP_NAME} PUBLIC __MACOSX_CORE__)


        #set_target_properties(${APP_NAME} PROPERTIES
        #        MACOSX_BUNDLE TRUE
        #        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/Info.plist"
        #)

        #        target_link_libraries(${APP_NAME}
        #                ${OF_CORE_LIBS}
        #                of_static
        #                #        ${opengl_lib}
        #                ${OF_CORE_FRAMEWORKS}
        #                ${USER_LIBS}
        #                ${OF_ADDONS}

        #        add_custom_command(
        #                TARGET ${APP_NAME}
        #                POST_BUILD
        #                COMMAND rsync
        #                ARGS -aved ${OF_ROOT}/libs/fmod/lib/osx/libfmod.dylib "$<TARGET_FILE_DIR:${APP_NAME}>/../Frameworks/"
        #        )
        #
        #        add_custom_command(
        #                TARGET ${APP_NAME}
        #                POST_BUILD
        #                COMMAND ${CMAKE_INSTALL_NAME_TOOL}
        #                ARGS -change @executable_path/libfmod.dylib @executable_path/../Frameworks/libfmod.dylib $<TARGET_FILE:${APP_NAME}>
        #        )

    elseif (OF_TARGET_VS)

        add_executable(${APP_NAME} "${SOURCE_FILES}")
        target_compile_options(${APP_NAME} PUBLIC
#                $<$<CONFIG:Debug>:/D _DEBUG /TP /Gy /Gs- /Od /ZI /MDd>
#                $<$<CONFIG:Release>:/O2 /W1>
                $<$<COMPILE_LANGUAGE:CXX>:/std:c++20>
                $<$<COMPILE_LANGUAGE:C>:/std:c17>
                /Zc:__cplusplus
#                /WX- /Zc:forScope /Gd /FC /EHsc /nologo  /Zc:inline /Zc:wchar_t /fp:precise)
#        #                -U__MINGW64__
#        #                -U__MINGW32__
        )
#        target_compile_definitions(${APP_NAME} PUBLIC
#                WIN32 CURL_STATICLIB URI_STATIC_BUILD _HAS_STREAM_INSERTION_OPERATORS_DELETED_IN_CXX20 _CONSOLE POCO_STATIC CAIRO_WIN32_STATIC_BUILD DISABLE_SOME_FLOATING_POINT OF_NO_FMOD GLM_FORCE_CTOR_INIT GLM_ENABLE_EXPERIMENTAL _UNICODE UNICODE FREEIMAGE_LIB)
        if (CMAKE_BUILD_TYPE MATCHES "Debug")
            #            target_link_options(${APP_NAME} PUBLIC
            #                    /DEBUG /NXCOMPAT /DYNAMICBASE /MACHINE:X64 /NODEFAULTLIB:"atlthunk.lib" /NODEFAULTLIB:MSVCRT /NODEFAULTLIB:"libcmt" /NODEFAULTLIB:"LIBC" /NODEFAULTLIB:"LIBCMTD" /INCREMENTAL /SUBSYSTEM:CONSOLE   /ERRORREPORT:PROMPT  /NOLOGO /TLBID:1 /FORCE:MULTIPLE
            #                 )
#            target_link_options(${APP_NAME} PUBLIC
#                    /DEBUG /DYNAMICBASE /MACHINE:X64 /INCREMENTAL /SUBSYSTEM:CONSOLE /ERRORREPORT:PROMPT /NOLOGO /FORCE:MULTIPLE
#            )
        else ()
            target_link_options(${APP_NAME} PUBLIC
                    /DYNAMICBASE:NO
                    /MACHINE:X64 /INCREMENTAL /FORCE:MULTIPLE /SUBSYSTEM:CONSOLE /NOLOGO /TLBID:1)
        endif ()
    endif ()

    set_target_properties(${APP_NAME}
            PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin
            OUTPUT_NAME ${OUTPUT_APP_NAME}
    )
    target_link_libraries(${APP_NAME} PRIVATE openframeworks::of_static)

endmacro()

function(ofPrintList LIST)
    foreach (ITEM IN LISTS ${LIST})
        message(STATUS ${ITEM})
    endforeach ()
endfunction()

function(ofGetSubdirNames result_var dir)
    # Get all children of dir
    file(GLOB children RELATIVE "${dir}" "${dir}/*")
    #    message("${children}")
    set(subdirs "")
    foreach (child ${children})
        if (IS_DIRECTORY "${dir}/${child}")
            list(APPEND subdirs "${child}")
        endif ()
    endforeach ()

    #    message(${subdirs})
    # Return result to caller scope
    set(${result_var} ${subdirs} PARENT_SCOPE)
endfunction()

#function(ofRemoveDebugLibs result_var the_list)
#    set(filtered_list "")
#    foreach (item IN LISTS the_list)
#        get_filename_component(name "${item}" NAME) # e.g. libD.lib
#        #        message(STATUS ${name})
#        if (NOT name MATCHES "D.lib")
#            list(APPEND filtered_list "${item}")
#        endif ()
#    endforeach ()
#    set(${result_var} "${filtered_list}" PARENT_SCOPE)
#endfunction()

# Target must be set or ofDetectTarget needs to be called prior to using this function
function(ofSetInstallPrefix)
    if (OF_TARGET_MACOS)
        set(_OF_PLATFORM "macos")
    elseif (OF_TARGET_VS)
        set(_OF_PLATFORM "vs")
    elseif (OF_TARGET_LINUX)
        set(_OF_PLATFORM "linux")
    else ()
        set(_OF_PLATFORM "unknown")
    endif ()
    message("Install Prefix: ${OF_DIRECTORY}/install/${_OF_PLATFORM}")
    set(OF_INSTALL_PREFIX "${OF_DIRECTORY}/install/${_OF_PLATFORM}" CACHE PATH "OF install path prefix" FORCE)
    set(CMAKE_INSTALL_PREFIX "${OF_DIRECTORY}/install/${_OF_PLATFORM}" CACHE PATH "OF install path prefix" FORCE)

endfunction()

ofDetectTarget()