function(listSubdirectories result curdir)
	file(GLOB_RECURSE children "${curdir}/*")
	set(dirlist "")

	foreach(child ${children})
		get_filename_component(child "${child}" DIRECTORY)
		list(APPEND dirlist ${child})
		list(REMOVE_DUPLICATES dirlist)
	endforeach()

	set(${result} ${dirlist} PARENT_SCOPE)
endfunction()

function(message_array _label _array)
	message(STATUS "${_label}:")
	foreach(_item ${${_array}})
		message(STATUS "  ${_item}")
	endforeach()
endfunction()

function(message_array_raw _label _array)
	message(STATUS "${_label}:")
	foreach(_item ${_array})
		message(STATUS "  ${_item}")
	endforeach()
endfunction()

function(message_array_indent _label _array _indent)
	message(STATUS "${_label}:")
	foreach(_item ${_array})
		message(STATUS "${_indent}${_item}")
	endforeach()
endfunction()

function(message_sdk _label _inc _lib)
	message(STATUS "${_label}:")
	message_array_indent("  Inc" "${_inc}" "    ")
	message_array_indent("  Lib" "${_lib}" "    ")
endfunction()

macro(add_executable_ext _target _sources _headers)
	if(UNIX)
		add_executable(${_target} ${_sources} ${_headers})
		set_target_properties(${_target} PROPERTIES SUFFIX ${MY_EXE_SUFFIX})
	else()
		add_executable(${_target} ${_sources} ${_headers})
	endif()
endmacro()

macro(add_executable_ext_gui _target _sources _headers _res)
	if(UNIX)
		add_executable(${_target} ${_sources} ${_headers} ${_res})
		set_target_properties(${_target} PROPERTIES SUFFIX ${MY_EXE_SUFFIX})
	else()
		add_executable(${_target} WIN32 ${_sources} ${_headers} ${_res})
	endif()
endmacro()

macro(add_shared_library _target _sources _headers)
	add_library(${_target} SHARED ${_sources} ${_headers})
endmacro()


macro(link_if_exist _lib_paths _libs)
	foreach(_lib_name ${_libs})
		find_library(
			${_lib_name}_exist # NOTE: This variable is cached - need unique name
			${_lib_name}
			PATHS ${_lib_paths}
			NO_DEFAULT_PATH
		)
		if(${_lib_name}_exist)
			list(APPEND LINK_LIBS ${_lib_name})
		endif()
	endforeach()
endmacro()


macro(vray_for_maya_link_if_exist _libs)
	link_if_exist("${VRAY_FOR_MAYA_LIBPATH}" "${_libs}")
	message(STATUS "Found libs: ${_libs}")
endmacro()

macro(vray_for_3dsmax_link_if_exist _libs)
	link_if_exist("${VRAY_FOR_3DSMAX_LIBPATH}" "${_libs}")
	message(STATUS "Found libs: ${_libs}")
endmacro()

macro(set_plugin_name _project _name)
	target_compile_definitions(${_project} PRIVATE
		-DPLUGIN_NAME=${_name}
	)
endmacro()

macro(bd_parse_version_h _filePath)
	file(STRINGS ${_filePath} VERSION_H)
	foreach(_line ${VERSION_H})
		string(REGEX MATCH "#define[\\t\\ ]+VERSION_MAJOR[\\t\\ ]+([0-9]+)" _match "${_line}")
		if (_match)
			set(VERSION_MAJOR ${CMAKE_MATCH_1})
		endif()
		string(REGEX MATCH "#define[\\t\\ ]+VERSION_MINOR[\\t\\ ]+([0-9]+)" _match "${_line}")
		if (_match)
			set(VERSION_MINOR ${CMAKE_MATCH_1})
		endif()
	endforeach()
	message(STATUS "Version: ${VERSION_MAJOR}.${VERSION_MINOR}")
endmacro()

function(bd_git_hash _dir _out_var)
	execute_process(
		COMMAND git rev-parse --short=8 HEAD
		WORKING_DIRECTORY ${_dir}
		OUTPUT_VARIABLE _out
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)
	set(${_out_var} "${_out}" PARENT_SCOPE)
endfunction()

function(file_glob_append _pattern _res)
	file(GLOB _files "${_pattern}")
	set(${_res} "${${_res}};${_files}" PARENT_SCOPE)
endfunction()

function(group_sources curdir)
	file(GLOB children RELATIVE ${PROJECT_SOURCE_DIR}/${curdir} ${PROJECT_SOURCE_DIR}/${curdir}/*)
	foreach(child ${children})
		if(IS_DIRECTORY ${PROJECT_SOURCE_DIR}/${curdir}/${child})
			group_sources(${curdir}/${child})
		else()
			string(REPLACE "/" "\\" groupname ${curdir})
			string(REPLACE "src\\" "" groupname ${groupname})
			source_group(${groupname} FILES ${PROJECT_SOURCE_DIR}/${curdir}/${child})
		endif()
	endforeach()
endfunction()
