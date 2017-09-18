if(UNIX)
	if(APPLE)
		set(OS "osx")
	else()
		set(OS "linux")
		add_definitions(
			-DLINUX
			-D_LINUX
		)
	endif()
	set(MY_EXE_SUFFIX ".bin")
elseif(WIN32)
	set(OS "windows")
	set(MY_EXE_SUFFIX ".exe")
else()
	set(OS "unknown")
endif()

if(WIN32)
	set(MOVE "move")
else()
	set(MOVE "mv")
endif()
