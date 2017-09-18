option(WITH_SECTIONS "Generate InstallBuilder sections file"  OFF)
set(SECTIONS_FILE "" CACHE FILEPATH "Sections file path")


macro(install_shared_library _target _path)
	if(WIN32)
		install(TARGETS ${_target} RUNTIME DESTINATION ${_path})
	else()
		install(TARGETS ${_target}         DESTINATION ${_path})
	endif()
endmacro()


macro(install_bin _target _path)
	if(WIN32)
		install(TARGETS ${_target} RUNTIME DESTINATION ${_path})
	else()
		install(TARGETS ${_target}         DESTINATION ${_path})
	endif()
endmacro()


macro(write_to_section
	_str)
	file(APPEND "${SECTIONS_FILE}" "${_str}")
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
			set(_pluginInstallDir ${_installDirVarName})
			set(_pluginInstallDir "\${${_pluginInstallDir}}")

			# Strip illigal chars from section name
			string(REPLACE "." "" _sectName "${_sectionName}")

			# Get target filename from intermediate file location
			cmake_policy(SET CMP0026 OLD) # TODO: convert to generator expression
			get_target_property(_output_filepath ${_target} LOCATION)
			get_filename_component(_output_filename ${_output_filepath} NAME)

			write_to_section("        <component>\n")
			write_to_section("            <name>${_sectName}</name>\n")
			write_to_section("            <canBeEdited>1</canBeEdited>\n")
			write_to_section("            <selected>0</selected>\n")
			write_to_section("            <show>1</show>\n")
			write_to_section("            <folderList>\n")
			write_to_section("                <folder>\n")
			write_to_section("                    <name>${_sectName}</name>\n")
			write_to_section("                    <destination>\${_pluginInstallDir}</destination>\n")
			write_to_section("                    <distributionFileList>\n")
			write_to_section("                        <distributionFile>\n")
			write_to_section("                            <origin>${_releasePath}/${_output_filename}</origin>\n")
			write_to_section("                        </distributionFile>\n")
			write_to_section("                    </distributionFileList>\n")
			write_to_section("                </folder>\n")
			write_to_section("            </folderList>\n")
			write_to_section("        </component>\n")
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