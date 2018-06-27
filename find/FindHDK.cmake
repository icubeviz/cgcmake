find_package(PackageHandleStandardArgs)

# Full requested Houdini version (like "16.0.600").
set(REQUESTED_HDK_VERSION ${HDK_FIND_VERSION_MAJOR}.${HDK_FIND_VERSION_MINOR}.${HDK_FIND_VERSION_PATCH})

if(USE_CONAN)
	vfh_install_xpak(PAK "HDK" VERSION ${REQUESTED_HDK_VERSION})
	set(VFH_SDK_HDK ${X_PAK}/HDK)
else()
	# HDK path in our internal SDK repository.
	set(VFH_SDK_HDK ${SDK_PATH}/hdk/${HDK_FIND_VERSION_MAJOR}.${HDK_FIND_VERSION_MINOR}/${HDK_FIND_VERSION_PATCH})

	# Add Qt version to path
	if(HDK_FIND_VERSION_MAJOR VERSION_GREATER 15)
		set(VFH_SDK_HDK ${VFH_SDK_HDK}/qt${HOUDINI_QT_VERSION})
	endif()
endif()

if(HDK_FIND_VERSION_MAJOR VERSION_GREATER 15)
	set(QT_TOOLS_PATH ${VFH_SDK_HDK}/bin)
endif()

# If installation path is not set use some default one.
if(NOT HOUDINI_INSTALL_ROOT)
	if(APPLE)
		set(HOUDINI_INSTALL_ROOT "/Applications/Houdini ${REQUESTED_HDK_VERSION}")
	elseif(WIN32)
		set(HOUDINI_INSTALL_ROOT "C:/Program Files/Side Effects Software/Houdini ${REQUESTED_HDK_VERSION}")
	else()
		set(HOUDINI_INSTALL_ROOT "/opt/hfs${REQUESTED_HDK_VERSION}")
	endif()
endif()


# Find out the current version by parsing HDK version from HDK version file
#
set(__SYS_VERSION_H "toolkit/include/SYS/SYS_Version.h")

# We could change the requested version of HDK -
# invalidate cache value in this case.
if(NOT REQUESTED_HDK_VERSION VERSION_EQUAL HDK_VERSION)
	unset(HDK_PATH CACHE)
endif()

message(STATUS "Searching for the HDK under:")
set(HDK_SEARCH_PATH)

if(EXISTS ${VFH_SDK_HDK})
	message(STATUS "  SDK: ${VFH_SDK_HDK}")
	list(APPEND HDK_SEARCH_PATH ${VFH_SDK_HDK})
elseif(EXISTS ${HOUDINI_INSTALL_ROOT})
	message(STATUS "  Installation: ${HOUDINI_INSTALL_ROOT}")
	list(APPEND HDK_SEARCH_PATH ${HOUDINI_INSTALL_ROOT})
endif()

if(NOT HDK_SEARCH_PATH)
	message(FATAL_ERROR "No HDK search paths found!")
endif()

find_path(HDK_PATH ${__SYS_VERSION_H}
	PATHS
		${HDK_SEARCH_PATH}
	NO_DEFAULT_PATH
)

set(HDK_VERSION_FILE ${HDK_PATH}/${__SYS_VERSION_H})
if(EXISTS ${HDK_VERSION_FILE})
	file(STRINGS "${HDK_VERSION_FILE}" HDK_MAJOR_VERSION REGEX "^#define[\t ]+SYS_VERSION_MAJOR_INT[\t ]+.*")
	file(STRINGS "${HDK_VERSION_FILE}" HDK_MINOR_VERSION REGEX "^#define[\t ]+SYS_VERSION_MINOR_INT[\t ]+.*")
	file(STRINGS "${HDK_VERSION_FILE}" HDK_BUILD_VERSION REGEX "^#define[\t ]+SYS_VERSION_BUILD_INT[\t ]+.*")
	file(STRINGS "${HDK_VERSION_FILE}" HDK_PATCH_VERSION REGEX "^#define[\t ]+SYS_VERSION_PATCH_INT[\t ]+.*")

	string(REGEX REPLACE "^.*SYS_VERSION_MAJOR_INT[\t ]+([0-9]*).*$" "\\1" HDK_MAJOR_VERSION "${HDK_MAJOR_VERSION}")
	string(REGEX REPLACE "^.*SYS_VERSION_MINOR_INT[\t ]+([0-9]*).*$" "\\1" HDK_MINOR_VERSION "${HDK_MINOR_VERSION}")
	string(REGEX REPLACE "^.*SYS_VERSION_BUILD_INT[\t ]+([0-9]*).*$" "\\1" HDK_BUILD_VERSION "${HDK_BUILD_VERSION}")
	string(REGEX REPLACE "^.*SYS_VERSION_PATCH_INT[\t ]+([0-9]*).*$" "\\1" HDK_PATCH_VERSION "${HDK_PATCH_VERSION}")

	set(HDK_VERSION "${HDK_MAJOR_VERSION}.${HDK_MINOR_VERSION}.${HDK_BUILD_VERSION}.${HDK_PATCH_VERSION}" CACHE INTERNAL "Parsed HDK version")
endif()

# Set include / library paths
#
if(APPLE)
	set(HDK_INCLUDES  "${HDK_PATH}/toolkit/include")
	set(HDK_LIBRARIES "${HDK_PATH}/Libraries")
elseif(WIN32)
	set(HDK_INCLUDES  "${HDK_PATH}/toolkit/include")
	set(HDK_LIBRARIES "${HDK_PATH}/custom/houdini/dsolib")
else()
	set(HDK_INCLUDES  "${HDK_PATH}/toolkit/include")
	set(HDK_LIBRARIES "${HDK_PATH}/dsolib")
endif()

find_package_handle_standard_args(HDK
	REQUIRED_VARS
		HDK_PATH HDK_INCLUDES HDK_LIBRARIES HDK_VERSION
	VERSION_VAR
		HDK_VERSION
)

# Check if we've found the correct version
#
set(FOUND_HDK_VERSION ${HDK_MAJOR_VERSION}.${HDK_MINOR_VERSION}.${HDK_BUILD_VERSION})
if(NOT REQUESTED_HDK_VERSION VERSION_EQUAL FOUND_HDK_VERSION)
	set(HDK_FOUND FALSE)
endif()

if(NOT HDK_FOUND AND HDK_FIND_REQUIRED)
	message(FATAL_ERROR "Found HDK ${FOUND_HDK_VERSION}, uncompatible with required version ${HDK_FIND_VERSION}")
endif()

if(HOUDINI_QT_VERSION VERSION_GREATER 4)
	set(HDK_QT_ROOT "${SDK_PATH}/hdk/qt/5.6.1" CACHE PATH "Qt 5.x for Houdini SDK root")
endif()

function(vfh_python_shell_wrapper _binVar _ldPath)
	set(filePath ${${_binVar}})
	get_filename_component(fileName ${filePath} NAME)

	set(outShellFilePath ${CMAKE_BINARY_DIR}/bin/${fileName})

	set(MY_LD_LIBRARY_PATH ${_ldPath})
	set(MY_PROCESS ${filePath})

	configure_file(${CMAKE_SOURCE_DIR}/cmake/vfh_shell_wrapper.cmake.in ${outShellFilePath} @ONLY)

	execute_process(COMMAND chmod +x ${outShellFilePath})

	set(${_binVar} ${outShellFilePath} PARENT_SCOPE)
endfunction()

if(HDK_FOUND)
	# NOTE: The exact list of compiler/linker flags can be obtained with:
	#   "hcustom --cflags / --ldflags"
	#
	set(HDK_DEFINITIONS
		-DAMD64
		-DSIZEOF_VOID_P=8
		-DSESI_LITTLE_ENDIAN
		-DFBX_ENABLED=1
		-DOPENCL_ENABLED=1
		-DOPENVDB_ENABLED=1
		-DBOOST_ALL_NO_LIB
		-DHBOOST_ALL_NO_LIB
	)

	if(HDK_MAJOR_VERSION VERSION_GREATER 15.0)
		# NOTE: openvdb_sesi is version 3.3.0, but HDK is using 4.0.0 API.
		if("${HDK_MAJOR_VERSION}.${HDK_MINOR_VERSION}" VERSION_LESS 16.5)
			list(APPEND HDK_DEFINITIONS
				-DOPENVDB_3_ABI_COMPATIBLE
			)
		endif()

		list(APPEND HDK_DEFINITIONS
			-DCXX11_ENABLED=1
			-DQT_NO_KEYWORDS=1
			-DQT_DLL
		)
	endif()

	set(HDK_INCLUDE_PATH ${HDK_INCLUDES})
	set(HDK_LIB_PATH     ${HDK_LIBRARIES})

	if(WIN32)
		set(PYTHON_ROOT         ${SDK_PATH}/hdk/python27)
		set(PYTHON_INCLUDE_PATH ${PYTHON_ROOT}/include)
		set(PYTHON_LIB_PATH     ${PYTHON_ROOT}/libs)
		set(PYTHON_BIN          ${PYTHON_ROOT}/python.exe)
	else()
		set(PYTHON_ROOT         ${SDK_PATH}/hdk/python)
		set(PYTHON_INCLUDE_PATH ${PYTHON_ROOT}/include/python2.7)
		set(PYTHON_LIB_PATH     ${PYTHON_ROOT}/lib)
		if(APPLE)
			set(PYTHON_BIN      /usr/bin/python)
		else()
			set(PYTHON_BIN      ${PYTHON_ROOT}/bin/python2.7-bin)
		endif()
	endif()

	if(NOT EXISTS ${PYTHON_BIN})
		message(FATAL_ERROR "Python \"${PYTHON_BIN}\" is not found!")
	else()
		if(NOT WIN32)
			vfh_python_shell_wrapper(PYTHON_BIN ${PYTHON_LIB_PATH})
		endif()

		message(STATUS "Using Python: ${PYTHON_BIN}")
	endif()

	set(HDK_INCLUDES
		${PYTHON_INCLUDE_PATH}
		${HDK_INCLUDE_PATH}
	)

	set(HDK_LIBRARIES
		${PYTHON_LIB_PATH}
		${HDK_LIB_PATH}
	)

	# For Windows linking
	if(HOUDINI_QT_VERSION VERSION_GREATER 4)
		list(APPEND HDK_DEFINITIONS
			-DUSE_QT5=1
		)

		list(APPEND HDK_INCLUDES
			${HDK_QT_ROOT}/include
			${HDK_QT_ROOT}/include/QtCore
			${HDK_QT_ROOT}/include/QtGui
			${HDK_QT_ROOT}/include/QtWidgets
		)

		if(NOT APPLE)
			list(APPEND HDK_LIBRARIES
				${HDK_QT_ROOT}/lib
			)
		endif()
	else()
		list(APPEND HDK_INCLUDES
			${HDK_INCLUDE_PATH}/QtCore
			${HDK_INCLUDE_PATH}/QtGui
		)
	endif()

	# For HDF5
	list(APPEND HDK_INCLUDES
		${SDK_PATH}/hdk/hdf5/include/cpp
		${HDK_INCLUDE_PATH}/OpenEXR
	)

	# Boost
	if("${HDK_MAJOR_VERSION}.${HDK_MINOR_VERSION}" VERSION_GREATER 16.0)
		# Since 16.5 Boost is not shipped anymore
		include_directories(${SDK_PATH}/hdk/boost/include)
		if(WIN32)
			list(APPEND HDK_LIBRARIES ${SDK_PATH}/hdk/boost/lib/vc14)
		elseif(APPLE)
			list(APPEND HDK_LIBRARIES ${SDK_PATH}/hdk/boost/lib/mavericks_x64/gcc-4.2-cpp)
		else()
			list(APPEND HDK_LIBRARIES ${SDK_PATH}/hdk/boost/lib/linux_x64/gcc-4.4)
		endif()
	else()
		list(APPEND HDK_INCLUDES
			${SDK_PATH}/hdk/boost_shared
		)
	endif()

	if(WIN32)
		list(APPEND HDK_DEFINITIONS
			-DI386
			-DWIN32
			-DSWAP_BITFIELDS
			-D_WIN32_WINNT=0x0502
			-DWINVER=0x0502
			-DNOMINMAX
			-DSTRICT
			-DWIN32_LEAN_AND_MEAN
			-D_USE_MATH_DEFINES
			-D_CRT_SECURE_NO_DEPRECATE
			-D_CRT_NONSTDC_NO_DEPRECATE
			-D_SCL_SECURE_NO_WARNINGS
			-DBOOST_ALL_NO_LIB
			-DEIGEN_MALLOC_ALREADY_ALIGNED=0
		)

		set(HDK_LIBS
			$<$<CONFIG:Release>:Half.lib>
			$<$<CONFIG:RelWithDebInfo>:Half.lib>
			openvdb_sesi.lib

			${SDK_PATH}/hdk/hdf5/lib/libhdf5_cpp$<$<CONFIG:Debug>:_D>.lib
			${SDK_PATH}/hdk/hdf5/lib/libhdf5$<$<CONFIG:Debug>:_D>.lib
		)

		if("${HDK_MAJOR_VERSION}.${HDK_MINOR_VERSION}" VERSION_GREATER 16.0)
			list(APPEND HDK_LIBS
				${HDK_LIB_PATH}/libARR.lib
				${HDK_LIB_PATH}/libAU.lib
				${HDK_LIB_PATH}/libBM.lib
				${HDK_LIB_PATH}/libBR.lib
				${HDK_LIB_PATH}/libBV.lib
				${HDK_LIB_PATH}/libCE.lib
				${HDK_LIB_PATH}/libCH.lib
				${HDK_LIB_PATH}/libCHOP.lib
				${HDK_LIB_PATH}/libCHOPNET.lib
				${HDK_LIB_PATH}/libCHOPZ.lib
				${HDK_LIB_PATH}/libCHUI.lib
				${HDK_LIB_PATH}/libCL.lib
				${HDK_LIB_PATH}/libCLO.lib
				${HDK_LIB_PATH}/libCMD.lib
				${HDK_LIB_PATH}/libCOP2.lib
				${HDK_LIB_PATH}/libCOPNET.lib
				${HDK_LIB_PATH}/libCOPZ.lib
				${HDK_LIB_PATH}/libcurlwrap.lib
				${HDK_LIB_PATH}/libCV.lib
				${HDK_LIB_PATH}/libCVEX.lib
				${HDK_LIB_PATH}/libDAE.lib
				${HDK_LIB_PATH}/libDD.lib
				${HDK_LIB_PATH}/libDEP.lib
				${HDK_LIB_PATH}/libDM.lib
				${HDK_LIB_PATH}/libDOP.lib
				${HDK_LIB_PATH}/libDOPZ.lib
				${HDK_LIB_PATH}/libDTUI.lib
				${HDK_LIB_PATH}/libEXPR.lib
				${HDK_LIB_PATH}/libFBX.lib
				${HDK_LIB_PATH}/libFONT.lib
				${HDK_LIB_PATH}/libFS.lib
				${HDK_LIB_PATH}/libFUI.lib
				${HDK_LIB_PATH}/libFUSE.lib
				${HDK_LIB_PATH}/libGA.lib
				${HDK_LIB_PATH}/libGABC.lib
				${HDK_LIB_PATH}/libGAS.lib
				${HDK_LIB_PATH}/libGD.lib
				${HDK_LIB_PATH}/libGDT.lib
				${HDK_LIB_PATH}/libGEO.lib
				${HDK_LIB_PATH}/libGOP.lib
				${HDK_LIB_PATH}/libGP.lib
				${HDK_LIB_PATH}/libGQ.lib
				${HDK_LIB_PATH}/libGR.lib
				${HDK_LIB_PATH}/libGSTY.lib
				${HDK_LIB_PATH}/libGT.lib
				${HDK_LIB_PATH}/libGU.lib
				${HDK_LIB_PATH}/libGUI.lib
				${HDK_LIB_PATH}/libGVEX.lib
				${HDK_LIB_PATH}/libHAPIL.lib
				${HDK_LIB_PATH}/libHARD.lib
				${HDK_LIB_PATH}/libHOM.lib
				${HDK_LIB_PATH}/libHOMF.lib
				${HDK_LIB_PATH}/libHOMUI.lib
				${HDK_LIB_PATH}/libhptex.lib
				${HDK_LIB_PATH}/libIM.lib
				${HDK_LIB_PATH}/libIMG.lib
				${HDK_LIB_PATH}/libIMG3D.lib
				${HDK_LIB_PATH}/libIMGUI.lib
				${HDK_LIB_PATH}/libIMH.lib
				${HDK_LIB_PATH}/libIMP.lib
				${HDK_LIB_PATH}/libIMS.lib
				${HDK_LIB_PATH}/libIPR.lib
				${HDK_LIB_PATH}/libJEDI.lib
				${HDK_LIB_PATH}/libJIVE.lib
				${HDK_LIB_PATH}/libKIN.lib
				${HDK_LIB_PATH}/libLM.lib
				${HDK_LIB_PATH}/libMATUI.lib
				${HDK_LIB_PATH}/libMCS.lib
				${HDK_LIB_PATH}/libMDS.lib
				${HDK_LIB_PATH}/libMGR.lib
				${HDK_LIB_PATH}/libMH.lib
				${HDK_LIB_PATH}/libMIDI.lib
				${HDK_LIB_PATH}/libMOT.lib
				${HDK_LIB_PATH}/libMPI.lib
				${HDK_LIB_PATH}/libMSS.lib
				${HDK_LIB_PATH}/libMT.lib
				${HDK_LIB_PATH}/libMWS.lib
				${HDK_LIB_PATH}/libOBJ.lib
				${HDK_LIB_PATH}/libOH.lib
				${HDK_LIB_PATH}/libOP.lib
				${HDK_LIB_PATH}/libOP3D.lib
				${HDK_LIB_PATH}/libOPUI.lib
				${HDK_LIB_PATH}/libPBR.lib
				${HDK_LIB_PATH}/libPI.lib
				${HDK_LIB_PATH}/libPOP.lib
				${HDK_LIB_PATH}/libPOPNET.lib
				${HDK_LIB_PATH}/libPOPZ.lib
				${HDK_LIB_PATH}/libPRM.lib
				${HDK_LIB_PATH}/libPSI2.lib
				${HDK_LIB_PATH}/libPXL.lib
				${HDK_LIB_PATH}/libPY.lib
				${HDK_LIB_PATH}/libPYP.lib
				${HDK_LIB_PATH}/libRAY.lib
				${HDK_LIB_PATH}/libRBD.lib
				${HDK_LIB_PATH}/libRE.lib
				${HDK_LIB_PATH}/libROP.lib
				${HDK_LIB_PATH}/libRU.lib
				${HDK_LIB_PATH}/libSHLF.lib
				${HDK_LIB_PATH}/libSHLFUI.lib
				${HDK_LIB_PATH}/libSHOP.lib
				${HDK_LIB_PATH}/libSI.lib
				${HDK_LIB_PATH}/libSIM.lib
				${HDK_LIB_PATH}/libSIMZ.lib
				${HDK_LIB_PATH}/libSOHO.lib
				${HDK_LIB_PATH}/libSOP.lib
				${HDK_LIB_PATH}/libSOPTG.lib
				${HDK_LIB_PATH}/libSOPZ.lib
				${HDK_LIB_PATH}/libSS.lib
				${HDK_LIB_PATH}/libSTM.lib
				${HDK_LIB_PATH}/libSTOR.lib
				${HDK_LIB_PATH}/libSTORUI.lib
				${HDK_LIB_PATH}/libSTY.lib
				${HDK_LIB_PATH}/libSYS.lib
				${HDK_LIB_PATH}/libTAKE.lib
				${HDK_LIB_PATH}/libTBF.lib
				${HDK_LIB_PATH}/libTHOR.lib
				${HDK_LIB_PATH}/libTIL.lib
				${HDK_LIB_PATH}/libtools.lib
				${HDK_LIB_PATH}/libTS.lib
				${HDK_LIB_PATH}/libUI.lib
				${HDK_LIB_PATH}/libUT.lib
				${HDK_LIB_PATH}/libVCC.lib
				${HDK_LIB_PATH}/libVEX.lib
				${HDK_LIB_PATH}/libVGEO.lib
				${HDK_LIB_PATH}/libVIS.lib
				${HDK_LIB_PATH}/libVISF.lib
				${HDK_LIB_PATH}/libVM.lib
				${HDK_LIB_PATH}/libVOP.lib
				${HDK_LIB_PATH}/libVOPNET.lib
				${HDK_LIB_PATH}/libVPRM.lib
				${HDK_LIB_PATH}/libWIRE.lib
				${HDK_LIB_PATH}/tbb.lib
				${HDK_LIB_PATH}/tbbmalloc.lib
			)
		else()
			file(GLOB HDK_LIBS_A "${HDK_LIB_PATH}/*.a")
			list(REMOVE_ITEM HDK_LIBS_A "${HDK_LIB_PATH}/libHARC32.a")
			list(APPEND HDK_LIBS ${HDK_LIBS_A})
		endif()

		if(HOUDINI_QT_VERSION VERSION_GREATER 4)
			list(APPEND HDK_LIBS
				${HDK_QT_ROOT}/lib/Qt5Core.lib
				${HDK_QT_ROOT}/lib/Qt5Gui.lib
				${HDK_QT_ROOT}/lib/Qt5Widgets.lib
			)
		else()
			list(APPEND HDK_LIBS
				${HDK_LIB_PATH}/QtCore4.lib
				${HDK_LIB_PATH}/QtGui4.lib
			)
		endif()

		list(APPEND HDK_LIBS
			advapi32
			comctl32
			comdlg32
			gdi32
			kernel32
			msvcprt
			msvcrt
			odbc32
			odbccp32
			oldnames
			ole32
			oleaut32
			shell32
			user32
			uuid
			winspool
			ws2_32
		)
	else()
		list(APPEND HDK_DEFINITIONS
			-D_GNU_SOURCE
			-DENABLE_THREADS
			-DENABLE_UI_THREADS
			-DUSE_PTHREADS
			-DGCC3
			-DGCC4
			-D_REENTRANT
			-D_FILE_OFFSET_BITS=64
		)

		set(HDK_LIBS
			HoudiniUI
			HoudiniOPZ
			HoudiniOP3
			HoudiniOP2
			HoudiniOP1
			HoudiniSIM
			HoudiniGEO
			HoudiniPRM
			HoudiniUT
		)

		if(APPLE)
			if("${HDK_MAJOR_VERSION}.${HDK_MINOR_VERSION}" VERSION_GREATER 16.0)
				set(HDK_LIBS
					${HDK_LIB_PATH}/libHoudiniAPPS3.dylib
					${HDK_LIB_PATH}/libHoudiniAPPS2.dylib
					${HDK_LIB_PATH}/libHoudiniUI.dylib
					${HDK_LIB_PATH}/libHoudiniUT.dylib
					${HDK_LIB_PATH}/libhboost_system.dylib
					${HDK_LIB_PATH}/libHoudiniPRM.dylib
					${HDK_LIB_PATH}/libHoudiniHARD.dylib
					${HDK_LIB_PATH}/libHoudiniHAPIL.dylib
					${HDK_LIB_PATH}/libHoudiniOP2.dylib
					${HDK_LIB_PATH}/libHoudiniOP1.dylib
					${HDK_LIB_PATH}/libHoudiniSIM.dylib
					${HDK_LIB_PATH}/libHoudiniGEO.dylib
					${HDK_LIB_PATH}/libHoudiniOPZ.dylib
					${HDK_LIB_PATH}/libHoudiniOP3.dylib
					${HDK_LIB_PATH}/libHoudiniAPPS1.dylib
					${HDK_LIB_PATH}/libHoudiniDEVICE.dylib
					HoudiniAPPS2
					HoudiniUI
					HoudiniUT
					HoudiniPRM
					HoudiniHARD
					HoudiniHAPIL
					HoudiniOP2
					HoudiniOP1
					HoudiniSIM
					HoudiniGEO
					HoudiniOPZ
					HoudiniOP3
					HoudiniAPPS1
					HoudiniDEVICE
				)
			endif()

			list(APPEND HDK_DEFINITIONS
				-DNEED_SPECIALIZATION_STORAGE
				-DMBSD
				-DMBSD_COCOA
				-DMBSD_INTEL
			)

			if(HOUDINI_QT_VERSION VERSION_GREATER 4)
				list(APPEND HDK_LIBS
					Qt5Core
					Qt5Gui
					Qt5Widgets
				)
			else()
				list(APPEND HDK_LIBS
					QtCore
					QtGui
				)
			endif()

			list(APPEND HDK_LIBS
				z
				dl
				tbb
				tbbmalloc
				pthread
				openvdb_sesi
				Half
				${SDK_PATH}/hdk/hdf5/lib/libhdf5$<$<CONFIG:Debug>:_debug>.a
				${SDK_PATH}/hdk/hdf5/lib/libhdf5_cpp$<$<CONFIG:Debug>:_debug>.a
				"-framework Cocoa"
			)
		else()
			list(APPEND HDK_DEFINITIONS
				-DLINUX
			)

			list(APPEND HDK_LIBS
				${SDK_PATH}/hdk/hdf5/lib/libhdf5_cpp$<$<CONFIG:Debug>:_debug>.a
				# NOTE: Our alembic_s will provide this.
				# ${SDK_PATH}/hdk/hdf5/lib/libhdf5$<$<CONFIG:Debug>:_debug>.a

				GLU
				GL
				X11
				Xext
				Xi
				dl
				pthread
			)
		endif()
	endif()
endif()

unset(__SYS_VERSION_H)
