include(CheckIncludeFileCXX)

if(3DSMAX_VERSION STREQUAL 2009)
	set(VRAY_VC "vc81r")
elseif(3DSMAX_VERSION STREQUAL 2010)
	set(VRAY_VC "vc91")
elseif(3DSMAX_VERSION STREQUAL 2011)
	set(VRAY_VC "vc91")
elseif(3DSMAX_VERSION STREQUAL 2012)
	set(VRAY_VC "vc91")
elseif(3DSMAX_VERSION STREQUAL 2013)
	set(VRAY_VC "vc101")
elseif(3DSMAX_VERSION STREQUAL 2014)
	set(VRAY_VC "vc101")
elseif(3DSMAX_VERSION STREQUAL 2018)
	set(VRAY_VC "vc14")
else()
	if(3DSMAX_VERSION STREQUAL 2017 AND
	   VRAY_VERSION STREQUAL 40
	)
		set(VRAY_VC "vc14")
		set(MSVC_COMPILER 2015)
	else()
		set(VRAY_VC "vc11")
		set(MSVC_COMPILER 2012)
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
		${SDK_ROOT}/vray/3dsmax/${VRAY_VERSION}/${3DSMAX_VERSION}/lib/${ARCH}
		${SDK_ROOT}/vray/3dsmax/${VRAY_VERSION}/${3DSMAX_VERSION}/lib/${ARCH}/${VRAY_VC}
	)
endif()

add_definitions(-DVRAY_EXPORTS -DVRAY_VERSION=${VRAY_VERSION})

message_array("Using V-Ray for 3dsmax SDK include path" VRAY_FOR_3DSMAX_INCPATH)
message_array("Using V-Ray for 3dsmax SDK library path" VRAY_FOR_3DSMAX_LIBPATH)

link_directories(${VRAY_FOR_3DSMAX_LIBPATH})

include_directories(${VRAY_FOR_3DSMAX_INCPATH})
set(CMAKE_REQUIRED_INCLUDES "${CMAKE_REQUIRED_INCLUDES};${VRAY_FOR_3DSMAX_INCPATH}")

set(VRAY_LIB_SUFFIX "_s")

if(3DSMAX_VERSION STREQUAL 2009)
	set(VRAY_LIB_SUFFIX "_sr")
endif()

set(VRAY_LIB_VERSION ${3DSMAX_VERSION})
if(3DSMAX_VERSION STREQUAL 2014 AND VRAY_VERSION LESS 30)
	set(VRAY_LIB_VERSION 2013)
endif()

set(VRAY_FOR_3DSMAX_LIBS
	plugman${VRAY_LIB_SUFFIX}
	putils${VRAY_LIB_SUFFIX}
	rayserver${VRAY_LIB_SUFFIX}
	vutils${VRAY_LIB_SUFFIX}
	zlib${VRAY_LIB_SUFFIX}

	vray${VRAY_LIB_VERSION}
	vrender${VRAY_LIB_VERSION}

	# Intel libs (from V-Ray SDK)
	libirc
	libircmt
	libmmd
	libmmt
)

macro(link_with_vray_for_3dsmax _target)
	target_link_libraries(${_target} ${VRAY_FOR_3DSMAX_LIBS})
endmacro()

macro(bd_init_vray_for_3dsmax)
	find_path(ICUBE_VRAY_HAS_GPU_MESH meshinstance.h PATHS ${VRAY_FOR_3DSMAX_INCPATH})
	if(ICUBE_VRAY_HAS_GPU_MESH)
		add_definitions(-DVRAY_GPU_MESH)
		list(APPEND VRAY_FOR_MAYA_LIBS
			meshinstance_s
		)
	endif()

	find_path(HAVE_PTRARRAY_HPP ptrarray.hpp PATHS ${VRAY_FOR_3DSMAX_INCPATH})
	if(HAVE_PTRARRAY_HPP)
		add_definitions(-DVRAY_HAVE_PTRARRAY)
	endif()

	CHECK_INCLUDE_FILE_CXX(vassert.h VRAY_HAS_VASSERT)
	if(VRAY_HAS_VASSERT)
		add_definitions(-DVRAY_HAS_VASSERT)
		if(CMAKE_BUILD_TYPE STREQUAL "Debug")
			add_definitions(-DVASSERT_ENABLED)
		endif()
	endif()

	CHECK_INCLUDE_FILE_CXX(mesh_objects_info.h VRAY_HAS_MESH_OBJECTS_INFO)
	if(VRAY_HAS_MESH_OBJECTS_INFO)
		add_definitions(-DVRAY_HAS_MESH_OBJECTS_INFO)
	endif()
endmacro()
