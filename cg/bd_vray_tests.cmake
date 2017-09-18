include(CheckCXXSourceCompiles)
include(CMakePushCheckState)

cmake_push_check_state()

macro(bd_find_library _out_var _lib_paths _lib_name)
    find_library(
        ${_out_var}
        ${_lib_name}
        PATHS ${_lib_paths}
        NO_DEFAULT_PATH
    )
    if (NOT ${${_out_var}})
        set(${_out_var} "" CACHE STRING "${_lib_name} was not found..." FORCE)
    endif()
endmacro()

bd_find_library(VUTILS_LIB "${VRAY_FOR_3DSMAX_LIBPATH};${VRAY_FOR_MAYA_LIBPATH}" vutils${VRAY_LIB_SUFFIX})

if(WIN32)
    bd_find_library(MMD_LIB "${VRAY_FOR_3DSMAX_LIBPATH};${VRAY_FOR_MAYA_LIBPATH}" libmmd)
    bd_find_library(IRC_LIB "${VRAY_FOR_3DSMAX_LIBPATH};${VRAY_FOR_MAYA_LIBPATH}" libirc)
    bd_find_library(SVML_DISPMD_LIB "${VRAY_FOR_3DSMAX_LIBPATH};${VRAY_FOR_MAYA_LIBPATH}" svml_dispmd)
    bd_find_library(LIBDECIMAL_LIB "${VRAY_FOR_3DSMAX_LIBPATH};${VRAY_FOR_MAYA_LIBPATH}" libdecimal)
endif()

message("${VUTILS_LIB} ${MMD_LIB}")

set(CMAKE_REQUIRED_LIBRARIES
    ${VUTILS_LIB}
    ${MMD_LIB}
    ${IRC_LIB}
    ${SVML_DISPMD_LIB}
    ${LIBDECIMAL_LIB}
)

CHECK_CXX_SOURCE_COMPILES("
#include <charstring.h>

using namespace VUtils;

int main(int argc, char const *argv[]) {
    CharString a(\"a\");
    CharString b(\"b\");

    if (a == b) {
        return 0;
    }

    return 1;
}
"
    VRAY_HAS_CHARSTRING_EQ
)

if (NOT VRAY_HAS_CHARSTRING_EQ)
    add_definitions(-DVRAY_CHARSTRING_NO_EQ)
endif()

cmake_pop_check_state()
