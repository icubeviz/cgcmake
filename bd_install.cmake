option(WITH_SECTIONS "Generate InstallBuilder sections file"  OFF)
set(SECTIONS_FILE "" CACHE FILEPATH "Sections file path")

macro(install_bin _target _path)
	if(WIN32)
		install(TARGETS ${_target} RUNTIME DESTINATION ${_path})
	else()
		install(TARGETS ${_target}         DESTINATION ${_path})
	endif()
endmacro()

macro(install_shared_library _target _path)
	install_bin(${_target} ${_path})
endmacro()

macro(install_release
	_target
	_releasePath
	_sectionName
	_installDirVarName
	)
	install_shared_library(${_target} ${_releasePath})

	if(WITH_SECTIONS)
		if(SECTIONS_FILE STREQUAL "")
			message(FATAL_ERROR "\${SECTIONS_FILE} is not set!")
		else()
			# Strip illigal chars from section name
			string(REPLACE "." "" _sectName "${_sectionName}")

			add_custom_command(TARGET ${_target} POST_BUILD
				COMMAND
					${CMAKE_COMMAND} -P ${BD_CMAKE}/bd_installbuilder_section.cmake
						# CMAKE_ARGV3: Sections file path
						"${SECTIONS_FILE}"
						# CMAKE_ARGV4: Section name
						"${_sectName}"
						# CMAKE_ARGV5: Install directory variable name
						"${_installDirVarName}"
						# CMAKE_ARGV6: Output file path
						"${_releasePath}/$<TARGET_FILE_NAME:${_target}>"
			)
		endif()
	endif()
endmacro()


macro(set_release_paths)
	set(PRODUCT_INSTALL_ROOT "${RDGROUP_RELEASE_ROOT}/${ICUBE_PRODUCT}")
endmacro()


macro(install_release_3dsmax
	_target)
	set_release_paths()

	set(RELEASE_PATH "${PRODUCT_INSTALL_ROOT}/${PROTECTION_SUBDIR}/${3DSMAX_VERSION}/${ARCH}")
	file(MAKE_DIRECTORY ${RELEASE_PATH})

	install_release(${_target}
		${RELEASE_PATH}
		"${_target}_3dsmax_\${3DSMAX_VERSION}_\${ARCH}"
		"smaxPluginPath"
	)
endmacro()

function(install_release_3dsmax_custom_var _target _installerPathVariable)
	set_release_paths()

	set(RELEASE_PATH "${PRODUCT_INSTALL_ROOT}/${PROTECTION_SUBDIR}/${3DSMAX_VERSION}/${ARCH}")
	file(MAKE_DIRECTORY ${RELEASE_PATH})

	install_release(${_target}
		${RELEASE_PATH}
		"${_target}_3dsmax_\${3DSMAX_VERSION}_\${ARCH}"
		"${_installerPathVariable}"
	)
endfunction()

macro(install_release_3dsmax_vray_custom_var
	_target
	_installerPathVariable
)
	set_release_paths()

	set(RELEASE_PATH "${PRODUCT_INSTALL_ROOT}/${PROTECTION_SUBDIR}/${3DSMAX_VERSION}/${VRAY_VERSION}/${ARCH}")
	file(MAKE_DIRECTORY ${RELEASE_PATH})

	install_release(${_target}
		${RELEASE_PATH}
		"${_target}_3dsmax_\${3DSMAX_VERSION}_vray_\${VRAY_VERSION}_\${ARCH}"
		"${_installerPathVariable}"
	)
endmacro()


macro(install_release_3dsmax_vray
	_target)
	set_release_paths()
	install_release_3dsmax_vray_custom_var(${_target} "smaxPluginPath")
endmacro()


macro(install_release_vray_for_maya
	_target
	_installerPathVariable
	)
	set_release_paths()

	set(RELEASE_PATH "${PRODUCT_INSTALL_ROOT}/plugins/${OS}/${PROTECTION_SUBDIR}/${MAYA_VERSION}/${VRAY_VERSION}/${ARCH}")
	file(MAKE_DIRECTORY ${RELEASE_PATH})

	install_release(${_target}
		${RELEASE_PATH}
		"${_target}_maya_\${MAYA_VERSION}_vray_\${VRAY_VERSION}_\${ARCH}_\${PROTECTION_SUBDIR}"
		"${_installerPathVariable}"
	)
endmacro()


macro(install_release_vray_for_maya_maya
	_target)
	install_release_vray_for_maya(${_target} "mayaPluginPath")
endmacro()


macro(install_release_vray_for_maya_vray
	_target)
	install_release_vray_for_maya(${_target} "vrayPluginPath")
endmacro()