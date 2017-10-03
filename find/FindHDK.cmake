find_package(PackageHandleStandardArgs)

# Full requested Houdini version (like "16.0.600").
set(REQUESTED_HDK_VERSION ${HDK_FIND_VERSION_MAJOR}.${HDK_FIND_VERSION_MINOR}.${HDK_FIND_VERSION_PATCH})

# HDK path in our internal SDK repository.
set(VFH_SDK_HDK ${SDK_PATH}/hdk/${HDK_FIND_VERSION_MAJOR}.${HDK_FIND_VERSION_MINOR}/${HDK_FIND_VERSION_PATCH})

# Add Qt version to path
if(HDK_FIND_VERSION_MAJOR VERSION_GREATER 15)
	set(VFH_SDK_HDK ${VFH_SDK_HDK}/qt${HOUDINI_QT_VERSION})
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
	set(HDK_INCLUDES  "${HDK_PATH}/../Resources/toolkit/include")
	set(HDK_LIBRARIES "${HDK_PATH}/../Libraries")
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
	message(WARNING "Found HDK ${FOUND_HDK_VERSION}, uncompatible with required version ${HDK_FIND_VERSION}")
endif()

if(HOUDINI_QT_VERSION VERSION_GREATER 4)
	set(HDK_QT_ROOT "${SDK_PATH}/hdk/qt/5.6.1" CACHE PATH "Qt 5.x for Houdini SDK root")
endif()

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
	)

	if(HDK_MAJOR_VERSION VERSION_GREATER 15.0)
		# NOTE: openvdb_sesi is version 3.3.0, but HDK is using 4.0.0 API.
		list(APPEND HDK_DEFINITIONS
			-DOPENVDB_3_ABI_COMPATIBLE
			-DCXX11_ENABLED=1
			-DQT_NO_KEYWORDS=1
			-DQT_DLL
		)
	endif()

	set(HDK_INCLUDE_PATH ${HDK_INCLUDES})
	set(HDK_LIB_PATH     ${HDK_LIBRARIES})

	if (WIN32)
		set(PYTHON_INCLUDE_PATH ${HDK_PATH}/python27/include)
		set(PYTHON_LIB_PATH ${HDK_PATH}/python27/libs)
	else()
		set(PYTHON_INCLUDE_PATH ${HDK_PATH}/python/include/python2.7)
		set(PYTHON_LIB_PATH ${HDK_PATH}/python/lib)
	endif()

	set(HDK_INCLUDES
		# For Boost spirit
		${PYTHON_INCLUDE_PATH}
		${SDK_PATH}/hdk/boost_shared
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

		list(APPEND HDK_LIBRARIES
			${HDK_QT_ROOT}/lib
		)
	else()
		list(APPEND HDK_INCLUDES
			${HDK_INCLUDE_PATH}/QtCore
			${HDK_INCLUDE_PATH}/QtGui
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

		if(WIN32)
			set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /D UT_ASSERT_LEVEL=1")
		endif()

		file(GLOB HDK_LIBS_A "${HDK_LIB_PATH}/*.a")

		set(HDK_LIBS
			${HDK_LIBS_A}
			$<$<CONFIG:Release>:Half.lib>
			$<$<CONFIG:RelWithDebInfo>:Half.lib>
			openvdb_sesi.lib
		)

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
			list(APPEND HDK_DEFINITIONS
				-DNEED_SPECIALIZATION_STORAGE
				-DMBSD
				-DMBSD_COCOA
				-DMBSD_INTEL
			)

			list(APPEND HDK_LIBS
				z
				dl
				tbb
				tbbmalloc
				pthread
				QtCore
				QtGui
				"-framework Cocoa"
			)
		else()
			list(APPEND HDK_DEFINITIONS
				-DLINUX
			)

			list(APPEND HDK_LIBS
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
