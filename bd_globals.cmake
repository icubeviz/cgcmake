include_directories(
	${ICUBE_GLOBALS}/include
)

if(UNIX)
	if(APPLE)
	else()
	endif()
else()
	add_definitions(
		-D_CRT_NONSTDC_NO_DEPRECATE
		-D_CRT_SECURE_NO_DEPRECATE
		-D_SCL_SECURE_NO_DEPRECATE
	)
endif()
