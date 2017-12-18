add_definitions(-DNDEBUG)

if(WIN32)
	include_directories(${COMPILER_INCLUDE})
	link_directories(${COMPILER_LIBPATH})

	set(CMAKE_CXX_FLAGS "/DWIN32 /D_WINDOWS /GR /EHsc /MD")

	# Enable multi core compilation
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP")

	if(MSVC_COMPILER STREQUAL "2015")
		# Write pdb from multiple cl.exe instances
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /FS")
	endif()

	set(CMAKE_CXX_FLAGS_RELEASE "/Ob1 /W0 /MD")
	set(CMAKE_CXX_FLAGS_DEBUG   "/Od /Ob0 /RTC1")

	if ("$ENV{ICUBE_USE_PDB}" STREQUAL "0")
		set(CMAKE_CXX_FLAGS_DEBUG           "${CMAKE_CXX_FLAGS_DEBUG} /Z7")
		set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "/debug /INCREMENTAL:NO")
	else()
		set(CMAKE_CXX_FLAGS_DEBUG   "${CMAKE_CXX_FLAGS_DEBUG} /Zi")
	endif()

	set(CMAKE_C_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
	set(CMAKE_C_FLAGS_DEBUG   "${CMAKE_CXX_FLAGS_DEBUG}")
	set(CMAKE_C_FLAGS         "${CMAKE_CXX_FLAGS}")

else()
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden")

	# Time measurement.
	# set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CMAKE_COMMAND} -E time")

	if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
		# Colored output.
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fcolor-diagnostics")

		# Disable some warnings for old SDK.
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-c++11-extensions -Wno-inconsistent-missing-override")

		option(USE_CLANG_THIN_LTO "Use Clang Think LTO" OFF)
		if(USE_CLANG_THIN_LTO)
			if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 3.8)
				set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -flto=thin")
				set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -flto=thin")
				set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -flto=thin")
			else()
				message(STATUS "Thin LTO is available starting from Clang 3.9.x!")
			endif()
		endif()
	endif()

	if(APPLE)
		if(WITH_LIBCPP)
			set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -stdlib=libc++")
		else()
			set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libstdc++")
		endif()
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -include ${SDK_ROOT}/maya/include/OpenMayaMac.h")
	else()
		set(WITH_CPP11 OFF)
		if(MAYA_VERSION EQUAL 2018 OR MAYA_VERSION GREATER 2018 OR)
			set(WITH_CPP11 ON)
		endif()
		if(VRAY_VERSION EQUAL 40 OR MAYA_VERSION GREATER 40 OR)
			set(WITH_CPP11 ON)
		endif()
		if(WITH_CPP11)
			set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
		endif()

		if(WITH_STATIC_LIBC)
			set(STATIC_LIBC "-static-libgcc -static-libstdc++")
			set(CMAKE_EXE_LINKER_FLAGS    "${CMAKE_EXE_LINKER_FLAGS} ${STATIC_LIBC}")
			set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${STATIC_LIBC}")
		endif()
	endif()

	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-write-strings")

	set(CMAKE_CXX_FLAGS_RELEASE "-O2 -w")
	set(CMAKE_CXX_FLAGS_DEBUG   "-O0 -g")

	set(CMAKE_C_FLAGS   "${CMAKE_CXX_FLAGS}")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility-inlines-hidden")

	if(NOT APPLE)
		set(CMAKE_CXX_CREATE_SHARED_LIBRARY "<CMAKE_CXX_COMPILER> <CMAKE_SHARED_LIBRARY_CXX_FLAGS> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <SONAME_FLAG><TARGET_SONAME> -o <TARGET> -Wl,--start-group <LINK_FLAGS> <OBJECTS> <LINK_LIBRARIES> -Wl,--end-group")
	endif()

	option(USE_SEPARATE_PDB "Use separate PDB file" OFF)
	if(USE_SEPARATE_PDB)
		set(SYMBOL_FILE "${CMAKE_BINARY_DIR}/<TARGET>.pdb")

		set(CMAKE_CXX_LINK_EXECUTABLE
			"${CMAKE_CXX_LINK_EXECUTABLE}"
			"mkdir -p $$(dirname ${SYMBOL_FILE})"
			"objcopy --only-keep-debug <TARGET> ${SYMBOL_FILE}"
			"objcopy --strip-debug <TARGET>"
			"objcopy --add-gnu-debuglink=${SYMBOL_FILE} <TARGET>")

		set(CMAKE_CXX_CREATE_SHARED_LIBRARY
			"${CMAKE_CXX_CREATE_SHARED_LIBRARY}"
			"mkdir -p $$(dirname ${SYMBOL_FILE})"
			"objcopy --only-keep-debug <TARGET> ${SYMBOL_FILE}"
			"objcopy --strip-debug <TARGET>"
			"objcopy --add-gnu-debuglink=${SYMBOL_FILE} <TARGET>")

		set(CMAKE_CXX_CREATE_SHARED_MODULE
			"${CMAKE_CXX_CREATE_SHARED_MODULE}"
			"mkdir -p $$(dirname ${SYMBOL_FILE})"
			"objcopy --only-keep-debug <TARGET> ${SYMBOL_FILE}"
			"objcopy --strip-debug <TARGET>"
			"objcopy --add-gnu-debuglink=${SYMBOL_FILE} <TARGET>")
	endif()
endif()
