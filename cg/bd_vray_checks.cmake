function(bd_vray_detect_vray_version _vray_inc_paths _vray_lib_paths)
    if(WITH_CUSTOM_VRAY OR WITH_INSTALLED_VRAY)
        find_file(VRAYBASE_H "vraybase.h"
            PATHS
                ${_vray_inc_paths}
            NO_DEFAULT_PATH
        )
        if(VRAYBASE_H)
            file(STRINGS ${VRAYBASE_H} VRAY_DLL_VERSION REGEX "^#define[\t ]+VRAY_DLL_VERSION[\t ]+.*")
            string(REGEX REPLACE "^.*VRAY_DLL_VERSION[\t ]+([x0-9]*).*$" "\\1" VRAY_DLL_VERSION "${VRAY_DLL_VERSION}")

            if(NOT VRAY_DLL_VERSION)
                set(VRAY_VERSION "40" CACHE STRING "" FORCE)
            else()
                string(SUBSTRING "${VRAY_DLL_VERSION}" 2 1 VRAY_VERSION_MAJOR)
                string(SUBSTRING "${VRAY_DLL_VERSION}" 3 1 VRAY_VERSION_MINOR)
                string(SUBSTRING "${VRAY_DLL_VERSION}" 5 2 VRAY_VERSION_BUILD)

                message(STATUS "Found V-Ray SDK: ${VRAY_VERSION_MAJOR}.${VRAY_VERSION_MINOR}.${VRAY_VERSION_BUILD}")

                set(VRAY_VERSION "${VRAY_VERSION_MAJOR}${VRAY_VERSION_MINOR}" CACHE STRING "" FORCE)
            endif()
        endif()
    endif()
endfunction()
