set(CMAKE_BUILD_TYPE_INIT "Release")
set(CMAKE_BUILD_TYPE      "Release" CACHE STRING "Build type")

# Check variables and convert slashes
# TODO: Check for thouse vars only if needed.
foreach(_env_var ICUBE_GLOBALS ICUBE_OUTPUT ICUBE_SDK ICUBE_INSTALLERS ICUBE_TMP)
    if ("$ENV{${_env_var}}" STREQUAL "")
        message(STATUS "Environment variable ${_env_var} is not set!")
    else()
        # Convert environment variable to local script
        set(${_env_var} $ENV{${_env_var}})

        # Convert slashes
        file(TO_CMAKE_PATH "${${_env_var}}" ${_env_var})

        message(STATUS "Using ${_env_var}: \"${${_env_var}}\"")
    endif()
endforeach()

set(SDK_ROOT "${ICUBE_SDK}" CACHE PATH "SDK location" FORCE)

set(RDGROUP_ROOT "${ICUBE_OUTPUT}")
set(RDGROUP_RELEASE_ROOT    "${RDGROUP_ROOT}/Release"    CACHE PATH "Release location")
set(RDGROUP_INSTALLERS_ROOT "${RDGROUP_ROOT}/Installers" CACHE PATH "Installers location")
set(ICUBE_NAMESPACE "E934A4E8-2D3A-4A3C-8B55-93272EC9CE2A")

set(DEVEL_ROOT    "$ENV{HOME}/install")
set(LOCAL_INSTALL "$ENV{HOME}/install/rdgroup")

get_filename_component(BD_CMAKE ${CMAKE_CURRENT_LIST_FILE} DIRECTORY)
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${BD_CMAKE}/cg;${BD_CMAKE}/compiler;${BD_CMAKE}/find")

set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD ON)

macro(bd_parse_version)
    file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/version.h" VERSION_MAJOR REGEX "^#define[\t ]+VERSION_MAJOR[\t ]+.*")
    string(REGEX REPLACE "^.*VERSION_MAJOR[\t ]+([0-9]*).*$" "\\1" VERSION_MAJOR "${VERSION_MAJOR}")

    file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/version.h" VERSION_MINOR REGEX "^#define[\t ]+VERSION_MINOR[\t ]+.*")
    string(REGEX REPLACE "^.*VERSION_MINOR[\t ]+([0-9]*).*$" "\\1" VERSION_MINOR "${VERSION_MINOR}")

    string(UUID PRODUCT_CODE NAMESPACE ${ICUBE_NAMESPACE} NAME "${PROJECT_NAME}" TYPE SHA1 UPPER)
    string(UUID UPDATE_CODE NAMESPACE ${ICUBE_NAMESPACE} NAME "${PROJECT_NAME}_${VERSION_MAJOR}.${VERSION_MINOR}" TYPE SHA1 UPPER)

    message(STATUS "${PROJECT_NAME} Version: ${VERSION_MAJOR}.${VERSION_MINOR}")
    if(WITH_RELEASE)
        message(STATUS "Product code: ${PRODUCT_CODE}")
        message(STATUS "Update code:  ${UPDATE_CODE}")
    endif()
endmacro()
