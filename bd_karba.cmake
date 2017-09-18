option(WITH_KARBA "Use Karba protection" OFF)
set(WITH_KARBA_ROOT "${SDK_ROOT}/protection/karba/lib" CACHE PATH "Karba protection location")

if(WITH_KARBA)
	set(PROTECTION_SUBDIR "karba")

	add_definitions(
		-DUSE_PROTECTION=1
	)

	include_directories(${WITH_KARBA_ROOT})
endif()

macro(karba_add_sources)
	if(WITH_KARBA)
		list(APPEND SOURCES
			${WITH_KARBA_ROOT}/data_encode.cpp
			${WITH_KARBA_ROOT}/protection.cpp
			${WITH_KARBA_ROOT}/system_info.cpp
			${WITH_KARBA_ROOT}/licence_manager.cpp
		)
	endif()
endmacro()
