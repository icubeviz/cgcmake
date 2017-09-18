set(RDG_COMPILER_ID "9.0" CACHE STRING "Visual Studio compiler ID")

option(RDG_COMPILER_FROM_ENV "Use Visual Studio compiler from environment" OFF)
option(RDG_USE_CLANG "Use Clang compiler" OFF)

if(RDG_USE_CLANG)
	# Smth...
	set(CMAKE_C_LINK_EXECUTABLE "clang" CACHE INTERNAL "")
	set(CMAKE_CXX_LINK_EXECUTABLE "clang++" CACHE INTERNAL "")

elseif(RDG_COMPILER_FROM_ENV)
	set(CMAKE_CXX_COMPILER "cl.exe" CACHE INTERNAL "")
	set(CMAKE_C_COMPILER   "cl.exe" CACHE INTERNAL "")

elseif(CMAKE_GENERATOR STREQUAL "Ninja")
	if(ARCH STREQUAL "x64")
		set(_X64   "/x64")
		set(_AMD64 "/amd64")
		set(_WIN64 "/win64/amd64")
	endif()

	if(MSVC_COMPILER STREQUAL "2005")
		set(RDG_COMPILER_ID "8.0" CACHE STRING "" FORCE)

		set(VC_ROOT     ${SDK_ROOT}/MSVC/2005)
		set(VC_EXE_PATH ${VC_ROOT}/VC/BIN${_AMD64})

		set(COMPILER_PATH
			${VC_EXE_PATH}
			${VC_ROOT}/Common7/IDE
			${VC_ROOT}/Common7/Tools
			${VC_ROOT}/Common7/Tools/bin
			${VC_ROOT}/SDK/v2.0/bin
			${VC_ROOT}/VC/BIN
			${VC_ROOT}/VC/PlatformSDK/bin${_WIN64}
			${VC_ROOT}/VC/PlatformSDK/bin
			${VC_ROOT}/VC/VCPackages
		)

		set(COMPILER_INCLUDE
			${VC_ROOT}/VC/ATLMFC/INCLUDE
			${VC_ROOT}/VC/INCLUDE
			${VC_ROOT}/VC/PlatformSDK/include
		)

		set(COMPILER_LIBPATH
			${VC_ROOT}/SDK/v2.0/lib${_AMD64}
			${VC_ROOT}/VC/ATLMFC/LIB${_AMD64}
			${VC_ROOT}/VC/LIB${_AMD64}
			${VC_ROOT}/VC/PlatformSDK/lib${_AMD64}
		)


	elseif(MSVC_COMPILER STREQUAL "2008")
		set(RDG_COMPILER_ID "9.0" CACHE STRING "" FORCE)

		set(VC_ROOT     ${SDK_ROOT}/MSVC/2008)
		set(VC_EXE_PATH ${VC_ROOT}/VC/BIN${_AMD64})

		set(COMPILER_PATH
			${VC_EXE_PATH}
			${SDK_ROOT}/MSVC/WindowsSDKs/v6.0A/bin${_X64}
			${VC_ROOT}/Common7/IDE
			${VC_ROOT}/Common7/Tools
			${VC_ROOT}/VC/VCPackages
		)

		set(COMPILER_LIBPATH
			${SDK_ROOT}/MSVC/WindowsSDKs/v6.0A/lib${_X64}
			${VC_ROOT}/VC/ATLMFC/LIB${_AMD64}
			${VC_ROOT}/VC/LIB${_AMD64}
		)

		set(COMPILER_INCLUDE
			${SDK_ROOT}/MSVC/WindowsSDKs/v6.0A/include
			${VC_ROOT}/VC/ATLMFC/INCLUDE
			${VC_ROOT}/VC/INCLUDE
		)

	elseif(MSVC_COMPILER STREQUAL "2010")
		set(RDG_COMPILER_ID "10.0" CACHE STRING "" FORCE)

		set(VC_ROOT     ${SDK_ROOT}/MSVC/2010)
		set(VC_EXE_PATH ${VC_ROOT}/VC/BIN${_AMD64})

		set(COMPILER_PATH
			${VC_EXE_PATH}
			${VC_ROOT}/VC/VCPackages
			${VC_ROOT}/Common7/IDE
			${VC_ROOT}/Common7/Tools
			${SDK_ROOT}/MSVC/WindowsSDKs/v7.0A/bin${_X64}
		)

		set(COMPILER_LIBPATH
			${SDK_ROOT}/MSVC/WindowsSDKs/v7.0A/lib${_X64}
			${SDK_ROOT}/MSVC/WindowsSDKs/v7.0A/lib
			${VC_ROOT}/VC/ATLMFC/LIB${_AMD64}
			${VC_ROOT}/VC/LIB${_AMD64}
		)

		set(COMPILER_INCLUDE
			${SDK_ROOT}/MSVC/WindowsSDKs/v7.0A/include
			${VC_ROOT}/VC/ATLMFC/INCLUDE
			${VC_ROOT}/VC/INCLUDE
		)

	elseif(MSVC_COMPILER STREQUAL "2012")
		set(RDG_COMPILER_ID "11.0" CACHE STRING "" FORCE)

		set(VC_ROOT     ${SDK_ROOT}/MSVC/2012)
		set(VC_EXE_PATH ${VC_ROOT}/VC/BIN${_AMD64})

		set(COMPILER_PATH
			${VC_EXE_PATH}
			${VC_ROOT}/VC/VCPackages
			${VC_ROOT}/Common7/IDE
			${VC_ROOT}/Common7/Tools
			${SDK_ROOT}/MSVC/WindowsSDKs/v7.0A/bin${_X64}
		)

		set(COMPILER_LIBPATH
			${SDK_ROOT}/MSVC/WindowsSDKs/v8.0/ExtensionSDKs/Microsoft.VCLibs/11.0/References/CommonConfiguration/neutral
			${SDK_ROOT}/MSVC/WindowsSDKs/v8.0/lib/win8/um/${ARCH}
			${SDK_ROOT}/MSVC/WindowsSDKs/v8.0/References/CommonConfiguration/Neutral
			${SDK_ROOT}/DotNET/v3.5
			${SDK_ROOT}/DotNET/v4.0.30319
			${VC_ROOT}/VC/ATLMFC/LIB${_AMD64}
			${VC_ROOT}/VC/LIB${_AMD64}
		)

		set(COMPILER_INCLUDE
			${VC_ROOT}/VC/INCLUDE
			${VC_ROOT}/VC/INCLUDE/thr
			${VC_ROOT}/VC/ATLMFC/INCLUDE
			${SDK_ROOT}/MSVC/WindowsSDKs/v8.0/include/shared
			${SDK_ROOT}/MSVC/WindowsSDKs/v8.0/include/um
			${SDK_ROOT}/MSVC/WindowsSDKs/v8.0/include/winrt
		)

		add_definitions(-D_USING_V110_SDK71_)

	elseif(MSVC_COMPILER STREQUAL "2015")
		set(RDG_COMPILER_ID "14.0" CACHE STRING "" FORCE)

		set(VC_ROOT     ${SDK_ROOT}/msvc/2015)
		set(VC_EXE_PATH ${VC_ROOT}/bin/amd64)

		set(COMPILER_INCLUDE
			${SDK_ROOT}/msvc/WindowsSDKs/v8.1/Include/shared
			${SDK_ROOT}/msvc/WindowsSDKs/v8.1/Include/um
			${SDK_ROOT}/msvc/WindowsSDKs/v8.1/Include/winrt
			${SDK_ROOT}/msvc/WindowsSDKs/v10/Include/10.0.10240.0/ucrt
			${VC_ROOT}/include
			${VC_ROOT}/atlmfc/include
		)

		set(COMPILER_LIBPATH
			${VC_ROOT}/lib/amd64
			${VC_ROOT}/lib/store/amd64
			${VC_ROOT}/atlmfc/lib/amd64
			${SDK_ROOT}/msvc/WindowsSDKs/v8.1/Lib/winv6.3/um/x64
			${SDK_ROOT}/msvc/WindowsSDKs/v10/Lib/10.0.10240.0/ucrt/x64
		)

		set(COMPILER_PATH
			${VC_EXE_PATH}
			${VC_ROOT}/bin/amd64/1033
			${VC_ROOT}/Common7/IDE
			${SDK_ROOT}/msvc/WindowsSDKs/v7.0A/bin/x64
		)
	endif()

	# Create build script for final compilation
	#
	# Set env for CMake tests
	# This is used to prevent recursive grow of %PATH%
	set(ORIG_PATH "$ENV{ORIG_PATH}")
	if(ORIG_PATH STREQUAL "")
		file(TO_CMAKE_PATH "$ENV{PATH}" ORIG_PATH)
		set(ENV{ORIG_PATH} "${ORIG_PATH}")
	endif()

	macro(set_env_paths_native env_var env_values)
		set(_env_list)
		foreach(_path ${env_values})
			file(TO_CMAKE_PATH ${_path} _native_path)
			list(APPEND _env_list ${_native_path})
		endforeach()
		set(ENV{${env_var}} "${_env_list}")
		message(STATUS "Setting ${env_var}: $ENV{${env_var}}")
	endmacro()

	set_env_paths_native(PATH    "${COMPILER_PATH};${ORIG_PATH}")
	set_env_paths_native(LIB     "${COMPILER_LIBPATH}")
	set_env_paths_native(LIBPATH "${COMPILER_LIBPATH}")
	set_env_paths_native(INCLUDE "${COMPILER_INCLUDE}")

	set(CMAKE_CXX_COMPILER  "${VC_EXE_PATH}/cl.exe"  CACHE INTERNAL "")
	set(CMAKE_C_COMPILER    "${VC_EXE_PATH}/cl.exe"  CACHE INTERNAL "")

	message(STATUS "Generating build.bat")
	file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/build.bat
		":: NOTE: This file is automatically generated!\n"
		"@echo off\n"
		"\n"
		"set ORIG_PATH=${ORIG_PATH}\n"
		"set PATH=$ENV{PATH}\n"
		"set LIB=$ENV{LIB}\n"
		"set LIBPATH=$ENV{LIBPATH}\n"
		"set INCLUDE=$ENV{INCLUDE}\n"
		"\n"
		"${ICUBE_GLOBALS}/bin/ninja.exe %*\n"
	)
endif()
