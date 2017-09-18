if(CMAKE_BUILD_TYPE STREQUAL "Debug")
	add_definitions(
		-DUSE_CONSOLE_DEBUG=1
		-DUSE_CERBER_DEBUG=1
		-DUSE_DEBUG=1
	)
else()
	add_definitions(
		-DUSE_DEBUG=0
	)
endif()
