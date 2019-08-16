option(BUILDING_CERBER      "Building Cerber libraries"  OFF)
option(WITH_CERBER          "Use Cerber protection"      OFF)
option(WITH_CERBER_SIGN     "Sign module"                ON)
option(WITH_CERBER_WRAPPER  "Use Cerber wrapper"         ON)

set(WITH_CERBER_ROOT      "${SDK_ROOT}/protection" CACHE PATH "Cerber root")
set(WITH_CERBER_DATA_ROOT "${SDK_ROOT}/protection/cerber-data" CACHE PATH "Cerber sign data root")

set(CERBER_INSTALL_SUBDIR $<LOWER_CASE:$<CONFIG>>)
if(WIN32)
	set(CERBER_INSTALL_ROOT "${WITH_CERBER_ROOT}/cerber-libs/windows/${CERBER_INSTALL_SUBDIR}/${ARCH}/${RDG_COMPILER_ID}")
elseif(APPLE)
	set(CERBER_INSTALL_ROOT "${WITH_CERBER_ROOT}/cerber-libs/mac/${CERBER_INSTALL_SUBDIR}")
else()
	set(CERBER_INSTALL_ROOT "${WITH_CERBER_ROOT}/cerber-libs/linux/${CERBER_INSTALL_SUBDIR}")
endif()

set(CERBER_INSTALL_BIN "${CERBER_INSTALL_ROOT}/bin")
set(CERBER_INSTALL_LIB "${CERBER_INSTALL_ROOT}/lib")

if(WIN32)
	set(CERBER_PROTECT "${WITH_CERBER_ROOT}/cerber-libs/windows/release/${ARCH}/${RDG_COMPILER_ID}/bin/cerberProtect.exe")
else()
	set(CERBER_PROTECT "${WITH_CERBER_DATA_ROOT}/bin/cerberProtect.bin")
endif()

set(SIGNATURE ${WITH_CERBER_DATA_ROOT}/RDGroup.signature)

set(CERBER_DEFINITIONS
	-DCERBER_DONT_CHECK_DEBUGGER
	-DCERBER_USE_FAKE_HARDID
	-D_FILE_OFFSET_BITS=64
	-DUSE_PROTECTION=2
	-DSALO_SSL=0
	-D_SALO_NO_SSL
)

if(BUILDING_CERBER)
	message(STATUS "Building Cerber: ${WITH_CERBER_ROOT}")
	add_definitions(${CERBER_DEFINITIONS})
elseif(WITH_CERBER)
	message(STATUS "Using Cerber: ${CERBER_INSTALL_ROOT}")
	message(STATUS "Using Cerber Protect: ${CERBER_PROTECT}")
	if(WITH_CERBER_WRAPPER)
		message(STATUS "Using Cerber wrapper: ${WITH_CERBER_WRAPPER}")
	endif()

	set(PROTECTION_SUBDIR "cerber")
endif()

function(link_with_cerber _target)
	if (NOT WITH_CERBER)
		return()
	endif()

	set(CERBER_INCLUDE_PATHS
		${WITH_CERBER_ROOT}/cerber-git/salo/include
		${WITH_CERBER_ROOT}/cerber-git/cerber/include
		${WITH_CERBER_ROOT}/cerber-git/cerber/common
		${WITH_CERBER_ROOT}/cerber-git/tcrypt/include
		${WITH_CERBER_ROOT}/cerber-git/libexpat/include
	)
	if(WITH_CERBER_WRAPPER)
		list(APPEND CERBER_INCLUDE_PATHS
			${WITH_CERBER_ROOT}/cerber-wrapper
		)
	endif()

	set(CERBER_LIBS
		${CERBER_INSTALL_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}cerber${CMAKE_STATIC_LIBRARY_SUFFIX}
		${CERBER_INSTALL_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}cerber_tools${CMAKE_STATIC_LIBRARY_SUFFIX}
		${CERBER_INSTALL_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}cerber_lm${CMAKE_STATIC_LIBRARY_SUFFIX}
		${CERBER_INSTALL_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}salo${CMAKE_STATIC_LIBRARY_SUFFIX}
		${CERBER_INSTALL_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}tcrypt${CMAKE_STATIC_LIBRARY_SUFFIX}
		${CERBER_INSTALL_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}expat${CMAKE_STATIC_LIBRARY_SUFFIX}
	)

	target_include_directories(${_target} PRIVATE ${CERBER_INCLUDE_PATHS})
	target_compile_definitions(${_target} PRIVATE ${CERBER_DEFINITIONS})
	target_link_libraries(${_target} PRIVATE ${CERBER_LIBS})
endfunction()


function(sign_with_cerber _target _product)
	set(PLUGIN_BIN $<TARGET_FILE:${_target}>)

	if(WIN32)
		# NOTE: Who could imagine "move" doesn't like "/"?
		string(REPLACE "/" "\\" PLUGIN_BIN ${PLUGIN_BIN})
	endif()

	set(PLUGIN_BIN_UNSIGNED ${PLUGIN_BIN}.unsigned)

	set(PRODUCT_KEY ${WITH_CERBER_DATA_ROOT}/productKeys/${_product}.key)
	message(STATUS "Using key: ${PRODUCT_KEY}")

	add_custom_command(TARGET ${_target}
		COMMENT "-- Signing ${_target} with ${_product}.key"
		POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E copy "${PLUGIN_BIN}" "${PLUGIN_BIN_UNSIGNED}"
		COMMAND ${CMAKE_COMMAND} -E remove "${PLUGIN_BIN}"
		COMMAND ${CERBER_PROTECT} -s "${SIGNATURE}" -p "${_product}" -k "${PRODUCT_KEY}" --module_in "${PLUGIN_BIN_UNSIGNED}" --module_out "${PLUGIN_BIN}"
		VERBATIM
	)
endfunction()


macro(sign_with_cerber_ex _target _product)
	if(WITH_CERBER AND WITH_CERBER_SIGN)
		sign_with_cerber(${_target} ${_product})
	endif()
endmacro()


macro(sign_cerber_lm _target)
	set(SERVER_BIN $<TARGET_FILE:${_target}>)

	if(WIN32)
		string(REPLACE "/" "\\" SERVER_BIN ${SERVER_BIN})
	endif()

	set(SERVER_BIN_UNSIGNED "${SERVER_BIN}.unsigned")

	add_custom_command(TARGET ${_target}
		COMMENT "-- Signing ${_target}..."
		POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E copy "${SERVER_BIN}" "${SERVER_BIN_UNSIGNED}"
		COMMAND ${CMAKE_COMMAND} -E remove "${SERVER_BIN}"
		COMMAND cerberProtect -s "${SIGNATURE}" --lm_in "${SERVER_BIN_UNSIGNED}" --lm_out "${SERVER_BIN}"
		VERBATIM
	)
endmacro()

macro(cerber_add_sources)
	if(WITH_CERBER)
		list(APPEND SOURCES
			${WITH_CERBER_ROOT}/cerber-wrapper/cerber_protection.cpp
			${WITH_CERBER_ROOT}/cerber-wrapper/cerber_wrapper.cpp
		)
	endif()
endmacro()
