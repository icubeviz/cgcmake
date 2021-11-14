function(bd_arnold_for_3dsmax_setup)
	if(3DSMAX_VERSION VERSION_LESS 2018)
		return()
	endif()
endfunction()

function(bd_arnold_for_3dsmax_setup_target _target)
	if(3DSMAX_VERSION VERSION_LESS 2018)
		return()
	endif()

	set(ARNOLD_SDK_ROOT ${SDK_ROOT}/arnold/7.0.0.0/core)

	set(ARNOLD_FOR_3DSMAX_LIBPATH
		${ARNOLD_SDK_ROOT}/lib/windows
	)

	set(ARNOLD_FOR_3DSMAX_INCPATH
		${ARNOLD_SDK_ROOT}/include
		${SDK_ROOT}/arnold/3dsmax/include
	)

	set(ARNOLD_FOR_3DSMAX_DEFINITIONS
		-DWITH_ARNOLD
	)

	set(ARNOLD_FOR_3DSMAX_LIBS
		ai.lib
	)

	target_compile_definitions(${_target} PRIVATE ${ARNOLD_FOR_3DSMAX_DEFINITIONS})
	target_include_directories(${_target} PRIVATE ${ARNOLD_FOR_3DSMAX_INCPATH})
	target_link_directories(${_target}    PRIVATE ${ARNOLD_FOR_3DSMAX_LIBPATH})
	target_link_libraries(${_target}      PRIVATE ${ARNOLD_FOR_3DSMAX_LIBS})
endfunction()
