set(LINUX_LINK_FLAGS
	rt
	dl
	pthread
)

set(CMAKE_INSTALL_SO_NO_EXE OFF)

macro(link_with_linux _target)
	target_link_libraries(${_target} PRIVATE ${LINUX_LINK_FLAGS})
endmacro()


set(OSX_LINK_FLAGS
	"-framework Foundation"
	"-framework IOKit"
	"-framework AGL"
	"-framework OpenGL"
)

macro(link_with_osx _target)
	target_link_libraries(${_target} PRIVATE ${OSX_LINK_FLAGS})
endmacro()
