function(bd_arnold_for_3dsmax_setup)
	if(3DSMAX_VERSION VERSION_LESS 2018)
		return()
	endif()

	set(ARNOLD_FOR_3DSMAX_LIBPATH
		${SDK_ROOT}/arnold/lib
	)

	link_directories(${ARNOLD_FOR_3DSMAX_LIBPATH})
endfunction()

function(bd_arnold_for_3dsmax_setup_target _target)
	if(3DSMAX_VERSION VERSION_LESS 2018)
		return()
	endif()

	set(ARNOLD_FOR_3DSMAX_INCPATH
		${SDK_ROOT}/arnold/3dsmax/include
		${SDK_ROOT}/arnold/include
	)

	set(ARNOLD_FOR_3DSMAX_DEFINITIONS
		-DWITH_ARNOLD
	)

	set(ARNOLD_FOR_3DSMAX_LIBS
		ai.lib
	)

	target_include_directories(${_target}
		PRIVATE
			${ARNOLD_FOR_3DSMAX_INCPATH}
	)

	target_link_libraries(${_target}
		${ARNOLD_FOR_3DSMAX_LIBS}
	)

	target_compile_definitions(${_target}
		PRIVATE
			${ARNOLD_FOR_3DSMAX_DEFINITIONS}
	)
endfunction()
