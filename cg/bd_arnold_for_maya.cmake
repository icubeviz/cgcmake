function(bd_arnold_for_maya_setup)
	if(MAYA_VERSION VERSION_LESS 2018)
		return()
	endif()

	set(ARNOLD_FOR_MAYA_LIBPATH
		${SDK_ROOT}/arnold/lib/${OS}
		${SDK_ROOT}/arnold/maya/${MAYA_VERSION}/lib/${OS}
	)

	link_directories(${ARNOLD_FOR_MAYA_LIBPATH})
endfunction()

function(bd_arnold_for_maya_setup_target _target)
	if(MAYA_VERSION VERSION_LESS 2018)
		return()
	endif()

	set(ARNOLD_FOR_MAYA_INCPATH
		${SDK_ROOT}/arnold/maya/${MAYA_VERSION}/include
		${SDK_ROOT}/arnold/include
	)

	set(ARNOLD_FOR_MAYA_LIBS
		ai.lib
		mtoa_api.lib
	)

	target_include_directories(${_target}
		PRIVATE
			${ARNOLD_FOR_MAYA_INCPATH}
	)

	target_link_libraries(${_target}
		${ARNOLD_FOR_MAYA_LIBS}
	)
endfunction()
