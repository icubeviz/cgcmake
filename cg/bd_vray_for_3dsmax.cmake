include(CheckIncludeFileCXX)
include(bd_vray_checks)

if(3DSMAX_VERSION VERSION_EQUAL 2009)
	set(VRAY_VC "vc81r")
endif()
if(3DSMAX_VERSION VERSION_EQUAL 2010)
	set(VRAY_VC "vc91")
endif()
if(3DSMAX_VERSION VERSION_EQUAL 2011)
	set(VRAY_VC "vc91")
endif()
if(3DSMAX_VERSION VERSION_EQUAL 2012)
	set(VRAY_VC "vc91")
endif()
if(3DSMAX_VERSION VERSION_EQUAL 2013)
	set(VRAY_VC "vc101")
endif()
if(3DSMAX_VERSION VERSION_EQUAL 2014)
	set(VRAY_VC "vc101")
endif()
if(3DSMAX_VERSION VERSION_GREATER_EQUAL 2015)
	set(VRAY_VC "vc11")
endif()
if(3DSMAX_VERSION VERSION_GREATER_EQUAL 2018)
	set(VRAY_VC "vc14")
endif()

if(VRAY_VERSION VERSION_GREATER_EQUAL 40)
	set(VRAY_VC "vc14")

	if(3DSMAX_VERSION VERSION_LESS 2023)
		set(MSVC_COMPILER 2017)
	endif()
endif()

set(VRAY_FOR_3DSMAX_LIBPATH)
set(VRAY_FOR_3DSMAX_INCPATH)

if(WITH_CUSTOM_VRAY)
	set(VRAY_FOR_3DSMAX_INCPATH ${WITH_VRAY_INCPATH})
	set(VRAY_FOR_3DSMAX_LIBPATH ${WITH_VRAY_LIBPATH})
else()
	set(VRAY_FOR_3DSMAX_INCPATH
		${SDK_ROOT}/vray/3dsmax/${VRAY_VERSION}/${3DSMAX_VERSION}/include
	)

	set(VRAY_FOR_3DSMAX_LIBPATH
		${SDK_ROOT}/vray/3dsmax/${VRAY_VERSION}/${3DSMAX_VERSION}/lib
		${SDK_ROOT}/vray/3dsmax/${VRAY_VERSION}/${3DSMAX_VERSION}/lib/${ARCH}
		${SDK_ROOT}/vray/3dsmax/${VRAY_VERSION}/${3DSMAX_VERSION}/lib/${ARCH}/${VRAY_VC}
	)
endif()

message_array("Using V-Ray for 3dsmax SDK include path" VRAY_FOR_3DSMAX_INCPATH)
message_array("Using V-Ray for 3dsmax SDK library path" VRAY_FOR_3DSMAX_LIBPATH)

set(CMAKE_REQUIRED_INCLUDES "${CMAKE_REQUIRED_INCLUDES};${VRAY_FOR_3DSMAX_INCPATH}")

set(VRAY_LIB_SUFFIX "_s")

if(3DSMAX_VERSION STREQUAL 2009)
	set(VRAY_LIB_SUFFIX "_sr")
endif()

set(VRAY_LIB_VERSION ${3DSMAX_VERSION})
if(3DSMAX_VERSION STREQUAL 2014 AND VRAY_VERSION LESS 30)
	set(VRAY_LIB_VERSION 2013)
endif()

set(VRAY_FOR_3DSMAX_DEFINITIONS
	-DVRAY_EXPORTS
)

set(VRAY_FOR_3DSMAX_LIBS
	plugman${VRAY_LIB_SUFFIX}
	putils${VRAY_LIB_SUFFIX}
	rayserver${VRAY_LIB_SUFFIX}
	vutils${VRAY_LIB_SUFFIX}
	zlib${VRAY_LIB_SUFFIX}

	vray${VRAY_LIB_VERSION}
	vrender${VRAY_LIB_VERSION}
)

# Intel libs (from V-Ray SDK, < 4.x only)
if(VRAY_VERSION LESS 40)
	list(APPEND VRAY_FOR_3DSMAX_LIBS
		libirc
		libircmt
		libmmd
		libmmt
	)
endif()

if(VRAY_VERSION GREATER_EQUAL 51)
	list(APPEND VRAY_FOR_3DSMAX_DEFINITIONS
		-DWITH_DR1
	)
endif()

macro(bd_init_vray_for_3dsmax)
	find_path(HAVE_PTRARRAY_HPP ptrarray.hpp PATHS ${VRAY_FOR_3DSMAX_INCPATH})
	if(HAVE_PTRARRAY_HPP)
		list(APPEND VRAY_FOR_3DSMAX_DEFINITIONS
			-DVRAY_HAVE_PTRARRAY
		)
	endif()

	if(VRAY_VERSION VERSION_GREATER_EQUAL 30)
		find_path(HAS_SHADEDATA_NEW shadedata_new.h PATHS ${VRAY_FOR_3DSMAX_INCPATH})
		if(HAS_SHADEDATA_NEW)
			list(APPEND VRAY_FOR_3DSMAX_DEFINITIONS
				-DVRAY_HAVE_SHADEDATA_NEW
			)
		endif()
	endif()

	CHECK_INCLUDE_FILE_CXX(vassert.h VRAY_HAS_VASSERT)
	if(VRAY_HAS_VASSERT)
		list(APPEND VRAY_FOR_3DSMAX_DEFINITIONS
			-DVRAY_HAS_VASSERT
			# $<$<CONFIG:Debug>:VASSERT_ENABLED>
		)
	endif()

	CHECK_INCLUDE_FILE_CXX(mesh_objects_info.h VRAY_HAS_MESH_OBJECTS_INFO)
	if(VRAY_HAS_MESH_OBJECTS_INFO)
		list(APPEND VRAY_FOR_3DSMAX_DEFINITIONS
			-DVRAY_HAS_MESH_OBJECTS_INFO
		)
	endif()

	bd_vray_detect_vray_version("${VRAY_FOR_3DSMAX_INCPATH}" "${VRAY_FOR_3DSMAX_LIBPATH}")
	list(APPEND VRAY_FOR_3DSMAX_DEFINITIONS
		-DVRAY_VERSION=${VRAY_VERSION}
	)

	find_path(VALLOC_CPP newdeleteoverload.cpp
		PATHS
			${VRAY_FOR_3DSMAX_INCPATH}
		PATH_SUFFIXES
			valloc_impl
		NO_DEFAULT_PAT
	)
endmacro()

function(bd_vray_for_3dsmax_setup_target _target)
	if(VALLOC_CPP)
		set(VALLOC_FILES
			${VALLOC_CPP}/newdeleteoverload.cpp
			${VALLOC_CPP}/vallocstub.cpp
		)

		target_sources(${_target} PRIVATE ${VALLOC_FILES})

		source_group("V-Ray SDK" FILES ${VALLOC_FILES})
	endif()

	target_compile_definitions(${_target} PRIVATE ${VRAY_FOR_3DSMAX_DEFINITIONS})
	target_include_directories(${_target}
		PRIVATE
			${VRAY_FOR_3DSMAX_INCPATH}
			${VRAY_FOR_3DSMAX_INCPATH}/maxutils # Introduced in 4.2
	)
	target_link_directories(${_target}    PRIVATE ${VRAY_FOR_3DSMAX_LIBPATH})
	target_link_libraries(${_target}      PRIVATE ${VRAY_FOR_3DSMAX_LIBS})
endfunction()
