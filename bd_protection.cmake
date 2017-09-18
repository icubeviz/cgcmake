set(PROTECTION_SUBDIR "none")

include(bd_cerber)
include(bd_karba)

if(WITH_CERBER AND WITH_KARBA)
	message(FATAL_ERROR "Can't use both protection systems at once!")
endif()

macro(protection_add_sources)
	if(WITH_CERBER)
		cerber_add_sources()
	else()
		karba_add_sources()
	endif()
endmacro()
