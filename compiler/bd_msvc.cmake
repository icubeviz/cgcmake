set(RDG_COMPILER_ID "9.0" CACHE STRING "Visual Studio compiler ID")

option(RDG_COMPILER_FROM_ENV "Use Visual Studio compiler from environment" OFF)
option(RDG_USE_CLANG "Use Clang compiler" OFF)

option(LOCAL_COMPILER "Use locally installed compiler" OFF)

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

	if(LOCAL_COMPILER)
		set(RDG_COMPILER_ID "14.1" CACHE STRING "" FORCE)
		set(VC_EXE_PATH "C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/VC/Tools/MSVC/14.16.27023/bin/HostX64/x64")

		set(COMPILER_INCLUDE
			"C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/VC/Tools/MSVC/14.16.27023/ATLMFC/include"
			"C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/VC/Tools/MSVC/14.16.27023/include"
			"C:/Program Files (x86)/Windows Kits/NETFXSDK/4.6.1/include/um"
			"C:/Program Files (x86)/Windows Kits/10/include/10.0.18362.0/ucrt"
			"C:/Program Files (x86)/Windows Kits/10/include/10.0.18362.0/shared"
			"C:/Program Files (x86)/Windows Kits/10/include/10.0.18362.0/um"
			"C:/Program Files (x86)/Windows Kits/10/include/10.0.18362.0/winrt"
			"C:/Program Files (x86)/Windows Kits/10/include/10.0.18362.0/cppwinrt"
		)

		set(COMPILER_LIBPATH
			"C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/VC/Tools/MSVC/14.16.27023/ATLMFC/lib/x64"
			"C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/VC/Tools/MSVC/14.16.27023/lib/x64"
			"C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/VC/Tools/MSVC/14.16.27023/lib/x86/store/references"
			"C:/Program Files (x86)/Windows Kits/10/lib/10.0.18362.0/ucrt/x64"
			"C:/Program Files (x86)/Windows Kits/10/lib/10.0.18362.0/um/x64"
			"C:/Program Files (x86)/Windows Kits/10/References/10.0.18362.0"
			"C:/Program Files (x86)/Windows Kits/10/UnionMetadata/10.0.18362.0"
			"C:/Program Files (x86)/Windows Kits/NETFXSDK/4.6.1/lib/um/x64"
			"C:/WINDOWS/Microsoft.NET/Framework64/v4.0.30319"
		)

		set(COMPILER_PATH
			${VC_EXE_PATH}
			"C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/Common7/IDE/VC/VCPackages"
			"C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/Common7/IDE/CommonExtensions/Microsoft/TestWindow"
			"C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/Common7/IDE/CommonExtensions/Microsoft/TeamFoundation/Team Explorer"
			"C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/MSBuild/15.0/bin/Roslyn"
			"C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/Team Tools/Performance Tools/x64"
			"C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/Team Tools/Performance Tools"
			"C:/Program Files (x86)/Microsoft Visual Studio/Shared/Common/VSPerfCollectionTools//x64"
			"C:/Program Files (x86)/Microsoft Visual Studio/Shared/Common/VSPerfCollectionTools/"
			"C:/Program Files (x86)/Microsoft SDKs/Windows/v10.0A/bin/NETFX 4.6.1 Tools/x64/"
			"C:/Program Files (x86)/HTML Help Workshop"
			"C:/Program Files (x86)/Windows Kits/10/bin/10.0.18362.0/x64"
			"C:/Program Files (x86)/Windows Kits/10/bin/x64"
			"C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional//MSBuild/15.0/bin"
			"C:/WINDOWS/Microsoft.NET/Framework64/v4.0.30319"
			"C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/Common7/IDE/"
			"C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/Common7/Tools/"
		)

	elseif(MSVC_COMPILER STREQUAL "2005")
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
	elseif(MSVC_COMPILER STREQUAL "2017")
		set(RDG_COMPILER_ID "14.1" CACHE STRING "" FORCE)

		set(VC_ROOT ${SDK_ROOT}/MSVC/2017)
		set(VC_EXE_PATH ${VC_ROOT}/BuildTools/VC/Tools/MSVC/14.12.25827/bin/HostX64/x64)

		set(COMPILER_INCLUDE
			${VC_ROOT}/ATLMFC/include
			${VC_ROOT}/include
			${SDK_ROOT}/msvc/WindowsSDKs/v10/include/10.0.16299.0/ucrt
			${SDK_ROOT}/msvc/WindowsSDKs/v10/include/10.0.16299.0/shared
			${SDK_ROOT}/msvc/WindowsSDKs/v10/include/10.0.16299.0/um
			${SDK_ROOT}/msvc/WindowsSDKs/v10/include/10.0.16299.0/winrt
		)

		set(COMPILER_LIBPATH
			${VC_ROOT}/ATLMFC/lib/x64
			${VC_ROOT}/lib/x64
			${VC_ROOT}/lib/x86/store/references
			${SDK_ROOT}/msvc/WindowsSDKs/v10/lib/10.0.16299.0/ucrt/x64
			${SDK_ROOT}/msvc/WindowsSDKs/v10/lib/10.0.16299.0/um/x64
			${SDK_ROOT}/msvc/WindowsSDKs/v10/References/10.0.16299.0
			${SDK_ROOT}/msvc/WindowsSDKs/v10/UnionMetadata/10.0.16299.0
		)

		set(COMPILER_PATH
			${VC_EXE_PATH}
			${SDK_ROOT}/msvc/WindowsSDKs/v10/bin/10.0.16299.0/x64
			${SDK_ROOT}/msvc/WindowsSDKs/v10/bin/x64
			${VC_ROOT}/BuildTools/Common7/IDE
			${VC_ROOT}/BuildTools/Common7/Tools
			${VC_ROOT}/BuildTools/MSBuild/15.0/bin
			${VC_ROOT}/BuildTools/MSBuild/15.0/bin/Roslyn
		)

	elseif(MSVC_COMPILER STREQUAL "2019")
		set(RDG_COMPILER_ID "14.3" CACHE STRING "" FORCE)

		set(VC_ROOT ${SDK_ROOT}/MSVC/2019)
		set(VC_EXE_PATH ${VC_ROOT}/bin/Hostx64/x64)

		set(COMPILER_INCLUDE
			${SDK_ROOT}/MSVC/WindowsSDKs/10.0.19041.0/include/shared
			${SDK_ROOT}/MSVC/WindowsSDKs/10.0.19041.0/include/ucrt
			${SDK_ROOT}/MSVC/WindowsSDKs/10.0.19041.0/include/um
			${SDK_ROOT}/MSVC/WindowsSDKs/10.0.19041.0/include/winrt
			${VC_ROOT}/atlmfc/include
			${VC_ROOT}/include
		)

		set(COMPILER_LIBPATH
			${SDK_ROOT}/MSVC/WindowsSDKs/10.0.19041.0/lib/ucrt/x64
			${SDK_ROOT}/MSVC/WindowsSDKs/10.0.19041.0/lib/um/x64
			${VC_ROOT}/atlmfc/lib/x64
			${VC_ROOT}/lib/x64
		)

		set(COMPILER_PATH
			${SDK_ROOT}/MSVC/WindowsSDKs/10.0.19041.0/bin/x64
			${VC_EXE_PATH}
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
		if(NOT LOCAL_COMPILER)
			message_array_raw("Setting ${env_var}" "$ENV{${env_var}}")
		endif()
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
		"setlocal\n"
		"\n"
		"set ORIG_PATH=${ORIG_PATH}\n"
		"set PATH=$ENV{PATH}\n"
		"set LIB=$ENV{LIB}\n"
		"set LIBPATH=$ENV{LIBPATH}\n"
		"set INCLUDE=$ENV{INCLUDE}\n"
		"\n"
		"${ICUBE_GLOBALS}/bin/ninja.exe %*\n"
		"if %ERRORLEVEL% NEQ 0 (\n"
		"  exit /B %ERRORLEVEL%\n"
		")\n"
		"endlocal\n"
	)
endif()
