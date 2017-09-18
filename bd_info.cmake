macro(print_info)
	message(STATUS "SDK: ${SDK_ROOT}")
	message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")
	message(STATUS "OS: ${OS}")
	message(STATUS "Architecture: ${ARCH}")
	message(STATUS "Compiler: ${RDG_COMPILER_ID} [${CMAKE_CXX_COMPILER}]")
	message(STATUS "Flags: ${CMAKE_CXX_FLAGS}")
	message(STATUS "  Release: ${CMAKE_CXX_FLAGS_RELEASE}")
	message(STATUS "  Debug: ${CMAKE_CXX_FLAGS_DEBUG}")

	message(STATUS "Linker: ${CMAKE_LINKER}")
	if(${CMAKE_SHARED_LINKER_FLAGS})
		message(STATUS "  Flags:  ${CMAKE_SHARED_LINKER_FLAGS}")
	endif()

	if(WIN32)
		message(STATUS "RC: ${CMAKE_RC_COMPILER}")
	endif()

	message(STATUS "Software:")

	if(DEFINED MAYA_VERSION)
		message(STATUS "  Maya:    ${MAYA_VERSION}")
	endif()

	if(DEFINED 3DSMAX_VERSION)
		message(STATUS "  3ds max: ${3DSMAX_VERSION}")
	endif()

	if(DEFINED VRAY_VERSION)
		message(STATUS "  V-Ray:   ${VRAY_VERSION}")
	endif()

	if(WITH_CERBER)
		message(STATUS "Protection: Cerber")
	elseif(WITH_KARBA)
		message(STATUS "Protection: Karba")
	else()
		message(STATUS "Protection: None")
	endif()

	message(STATUS "Install:")
	message(STATUS "  Sections filepath: ${SECTIONS_FILE}")
endmacro()
