include(CheckCXXSourceCompiles)
include(CheckIncludeFileCXX)
include(bd_vray_checks)

set(VRAY_FOR_MAYA_LOCAL_INSTALL_PATH "${LOCAL_INSTALL}/vray_for_maya/${OS}/${MAYA_VERSION}/${ARCH}" CACHE PATH "")

set(VRAY_FOR_MAYA_SEARCH_INCPATH)
set(VRAY_FOR_MAYA_SEARCH_LIBPATH)

if(WITH_INSTALLED_VRAY)
	if(WIN32)
		set(VRAY_FOR_MAYA_INCPATH        "C:/Program Files/Chaos Group/V-Ray/Maya ${MAYA_VERSION} for x64/include")
		set(VRAY_FOR_MAYA_SEARCH_LIBPATH "C:/Program Files/Chaos Group/V-Ray/Maya ${MAYA_VERSION} for x64/lib")
	elseif(APPLE)
		set(VRAY_FOR_MAYA_INCPATH        "/Applications/ChaosGroup/V-Ray/Maya${MAYA_VERSION}/include")
		set(VRAY_FOR_MAYA_SEARCH_LIBPATH "/Applications/ChaosGroup/V-Ray/Maya${MAYA_VERSION}/lib")
	else()
		set(VRAY_FOR_MAYA_INCPATH        "/usr/ChaosGroup/V-Ray/Maya${MAYA_VERSION}-x64/include")
		set(VRAY_FOR_MAYA_SEARCH_LIBPATH "/usr/ChaosGroup/V-Ray/Maya${MAYA_VERSION}-x64/lib")
	endif()
elseif(WITH_CUSTOM_VRAY)
	set(VRAY_FOR_MAYA_INCPATH        "${WITH_VRAY_INCPATH}")
	set(VRAY_FOR_MAYA_SEARCH_LIBPATH "${WITH_VRAY_LIBPATH}")
else()
	set(VRAY_FOR_MAYA_INCPATH        "${SDK_ROOT}/vray/maya/${VRAY_VERSION}/${OS}/${MAYA_VERSION}/include")
	set(VRAY_FOR_MAYA_SEARCH_LIBPATH "${SDK_ROOT}/vray/maya/${VRAY_VERSION}/${OS}/${MAYA_VERSION}/lib")
	if(WIN32)
		set(VRAY_FOR_MAYA_SEARCH_LIBPATH
			${VRAY_FOR_MAYA_SEARCH_LIBPATH}
			${VRAY_FOR_MAYA_SEARCH_LIBPATH}/${ARCH}
		)
	endif()
endif()

set(VRAY_FOR_MAYA_LIBS
	plugman_s
	putils_s
	vutils_s
)

set(CMAKE_REQUIRED_INCLUDES "${CMAKE_REQUIRED_INCLUDES};${VRAY_FOR_MAYA_INCPATH}")

listSubdirectories(VRAY_FOR_MAYA_SEARCH_LIBPATHS ${VRAY_FOR_MAYA_SEARCH_LIBPATH})

find_library(TIFF_S NAMES tiff_s PATHS ${VRAY_FOR_MAYA_SEARCH_LIBPATHS})
get_filename_component(VRAY_FOR_MAYA_LIBPATH_1 "${TIFF_S}" DIRECTORY)
if (VRAY_FOR_MAYA_LIBPATH_1)
	list(APPEND VRAY_FOR_MAYA_LIBPATH ${VRAY_FOR_MAYA_LIBPATH_1})
endif()

find_library(VUTILS_S NAMES vutils_s PATHS ${VRAY_FOR_MAYA_SEARCH_LIBPATHS})
get_filename_component(VRAY_FOR_MAYA_LIBPATH_2 "${VUTILS_S}" DIRECTORY)
if (VRAY_FOR_MAYA_LIBPATH_2)
	list(APPEND VRAY_FOR_MAYA_LIBPATH ${VRAY_FOR_MAYA_LIBPATH_2})
endif()

list(REMOVE_DUPLICATES VRAY_FOR_MAYA_LIBPATH)

list(APPEND VRAY_FOR_MAYA_INCPATH ${VRAY_FOR_MAYA_INCPATH}/vray_maya_sdk)

# This is needed only for old V-Ray SDK's, but still...
list(APPEND VRAY_FOR_MAYA_INCPATH ${SDK_ROOT}/vray/include)
list(REMOVE_DUPLICATES VRAY_FOR_MAYA_INCPATH)

list(APPEND VRAY_FOR_MAYA_INCPATH
	${SDK_ROOT}/qt/${OS}/maya/${MAYA_VERSION}/include
)
list(APPEND VRAY_FOR_MAYA_LIBPATH
	${SDK_ROOT}/qt/${OS}/maya/${MAYA_VERSION}/lib
)

file(TO_CMAKE_PATH "${VRAY_FOR_MAYA_INCPATH}" VRAY_FOR_MAYA_INCPATH)
file(TO_CMAKE_PATH "${VRAY_FOR_MAYA_LIBPATH}" VRAY_FOR_MAYA_LIBPATH)

if(VRAY_VERSION VERSION_GREATER_EQUAL 41)
	set(VRAY_HAS_MESH_OBJECTS_INFO            ON)
	set(VRAY_HAS_EXT_VRAYSCENE_OVERRIDE_INFO  ON)
	set(VRAY_HAS_EXT_VRAYSCENE_GENERATOR_INFO ON)
	set(VRAY_HAS_EXT_VRAYSCENE_SOURCE         ON)
	set(VRAY_HAS_EXT_VRAYSCENE_MANAGER        ON)

	set(VRAY_HAS_VASSERT  ON)
	set(HAVE_PTRARRAY_HPP OFF)
	set(HAVE_PTRARRAY_H   ON)
else()
	find_path(HAVE_PTRARRAY_HPP ptrarray.hpp PATHS ${VRAY_FOR_MAYA_INCPATH})
	find_path(HAVE_PTRARRAY_H ptrarray.h PATHS ${VRAY_FOR_MAYA_INCPATH})

	CHECK_INCLUDE_FILE_CXX(vassert.h VRAY_HAS_VASSERT)
	CHECK_INCLUDE_FILE_CXX(mesh_objects_info.h VRAY_HAS_MESH_OBJECTS_INFO)

	CHECK_CXX_SOURCE_COMPILES("
	#include <vrayplugins.h>

	using namespace VUtils;

	int main(int argc, char const *argv[]) {
	InterfaceID ifaceId = EXT_VRAYSCENE_SOURCE;
	return 0;
	}
	"
		VRAY_HAS_EXT_VRAYSCENE_SOURCE
	)

	CHECK_CXX_SOURCE_COMPILES("
	#include <vrayplugins.h>

	using namespace VUtils;

	int main(int argc, char const *argv[]) {
	InterfaceID ifaceId = EXT_VRAYSCENE_GENERATOR_INFO;
	return 0;
	}
	"
		VRAY_HAS_EXT_VRAYSCENE_GENERATOR_INFO
	)

	CHECK_CXX_SOURCE_COMPILES("
	#include <vrayplugins.h>

	using namespace VUtils;

	int main(int argc, char const *argv[]) {
	InterfaceID ifaceId = EXT_VRAYSCENE_OVERRIDE_INFO;
	return 0;
	}
	"
		VRAY_HAS_EXT_VRAYSCENE_OVERRIDE_INFO
	)

	CHECK_CXX_SOURCE_COMPILES("
	#include <vraypluginrenderer_interfaces.h>

	using namespace VUtils;

	int main(int argc, char const *argv[]) {
	InterfaceID ifaceId = EXT_VRAYSCENE_MANAGER;
	return 0;
	}
	"
		VRAY_HAS_EXT_VRAYSCENE_MANAGER
	)

	CHECK_CXX_SOURCE_COMPILES("
	#include <utils.h>
	#include <ssetypes.h>

	int main(int argc, char const *argv[]) {
	return 0;
	}
	"
		VRAY_COMPILER_HAS_SSE
	)

	CHECK_CXX_SOURCE_COMPILES("
	#include <vrayplugins.h>

	using namespace VUtils;

	#ifndef EXT_EXTERNAL_MAP_CHANNELS
	struct VrsRayserverExternalMapChannels {};
	#else
	static Table<MapChannel> mapChannelsTable;
	struct VrsRayserverExternalMapChannels
		: ExternalMapChannels
	{
		PluginBase *getPlugin() VRAY_OVERRIDE { return NULL; }

		int getChannelIndex(const StringID &channelName) const VRAY_OVERRIDE {
			return -1;
		}

		Vector getValue(const VRayContext &rc, const StringID &channelName) const VRAY_OVERRIDE {
			return Vector(0.0f);
		}

		Vector getValue(const VRayContext &rc, int channelIndex) const VRAY_OVERRIDE {
			return Vector(0.0f);
		}

		const Table<MapChannel> & getChannels() const VRAY_OVERRIDE {
			return mapChannelsTable;
		}
	};
	#endif

	int main(int argc, char const *argv[]) {
		VrsRayserverExternalMapChannels mapChannels;
		return 0;
	}
	"
		VRAY_HAS_OLD_MAP_CHANNELS
	)
endif()

if(NOT VRAY_HAS_OLD_MAP_CHANNELS)
	add_definitions(-DVRAY_NEXT_MAP_CHANNELS)
endif()

string(REGEX MATCH "\\-cpp" VRAY_SDK_LIBCPP ${VRAY_FOR_MAYA_LIBPATH})
if(VRAY_SDK_LIBCPP)
	set(WITH_LIBCPP ON CACHE BOOL "" FORCE)
endif()

macro(bd_add_define_if _var)
	if(${_var})
		list(APPEND VRAY_FOR_MAYA_DEFS -D${_var})
	endif()
endmacro()

macro(bd_init_vray_for_maya)
	message_sdk("V-Ray for Maya SDK" "${VRAY_FOR_MAYA_INCPATH}" "${VRAY_FOR_MAYA_LIBPATH}")

	set(VRAY_FOR_MAYA_DEFS
		-DVRAY_EXPORTS
		-DVRAY_VERSION=${VRAY_VERSION}
		-DWITH_DR1
	)

	if(ICUBE_VRAY_HAS_GPU_MESH)
		list(APPEND VRAY_FOR_MAYA_DEFS -DVRAY_GPU_MESH)
	endif()

	if(VRAY_HAS_VASSERT)
		list(APPEND VRAY_FOR_MAYA_DEFS -DVRAY_HAS_VASSERT)
		if (WIN32)
			set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /DVASSERT_ENABLED")
		endif()
	endif()

	if(HAVE_PTRARRAY_HPP)
		list(APPEND VRAY_FOR_MAYA_DEFS -DVRAY_HAVE_PTRARRAY)
	endif()

	if(HAVE_PTRARRAY_H)
		list(APPEND VRAY_FOR_MAYA_DEFS -DVRAY_HAS_PTRARRAY_H)
	endif()

	bd_add_define_if(VRAY_HAS_MESH_OBJECTS_INFO)
	bd_add_define_if(VRAY_HAS_EXT_VRAYSCENE_OVERRIDE_INFO)
	bd_add_define_if(VRAY_HAS_EXT_VRAYSCENE_GENERATOR_INFO)
	bd_add_define_if(VRAY_HAS_EXT_VRAYSCENE_SOURCE)
	bd_add_define_if(VRAY_HAS_EXT_VRAYSCENE_MANAGER)

	bd_vray_detect_vray_version("${VRAY_FOR_MAYA_INCPATH}" "${VRAY_FOR_MAYA_LIBPATH}")

	if(VRAY_VERSION VERSION_LESS 40)
		# if(NOT VRAY_COMPILER_HAS_SSE)
		# 	list(APPEND VRAY_FOR_MAYA_DEFS -DNO_SSE)
		# endif()
	else()
		list(APPEND VRAY_FOR_MAYA_DEFS -DWITH_DR2)

		if(VRAY_VERSION VERSION_GREATER_EQUAL 51)
			if(WIN32)
				list(APPEND VRAY_FOR_MAYA_DEFS -D__SSE4_1__)
			endif()
		endif()
	endif()

	find_path(VALLOC_CPP newdeleteoverload.cpp
		PATHS
			${VRAY_FOR_MAYA_INCPATH}
		PATH_SUFFIXES
			valloc_impl
		NO_DEFAULT_PAT
	)
endmacro()

list(APPEND VRAY_FOR_MAYA_LIBS
	vray
)

if(WIN32)
	list(APPEND VRAY_FOR_MAYA_LIBS
		zlib_s
	)
elseif(APPLE)
	list(APPEND VRAY_FOR_MAYA_LIBS
		"-framework Cocoa"
		pthread
		z
	)
else()
	if(VRAY_VERSION GREATER 24)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-int-to-pointer-cast")
	endif()
	list(APPEND VRAY_FOR_MAYA_LIBS
		z
	)
endif()

function(link_with_vray_for_maya _target)
	if(APPLE)
		set_target_properties(${_target}
			PROPERTIES
				PREFIX "lib"
				SUFFIX ".so"
		)
	endif()

	if(VALLOC_CPP)
		set(VALLOC_FILES
			${VALLOC_CPP}/newdeleteoverload.cpp
			${VALLOC_CPP}/vallocstub.cpp
		)

		target_sources(${_target} PRIVATE ${VALLOC_FILES})

		source_group("V-Ray SDK" FILES ${VALLOC_FILES})
	endif()

	target_compile_definitions(${_target} PRIVATE ${VRAY_FOR_MAYA_DEFS})
	target_include_directories(${_target} PRIVATE ${VRAY_FOR_MAYA_INCPATH})
	target_link_directories(${_target}    PRIVATE ${VRAY_FOR_MAYA_LIBPATH})
	target_link_libraries(${_target}      PRIVATE ${VRAY_FOR_MAYA_LIBS})
endfunction()
