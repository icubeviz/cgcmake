set(WINDOWS_LINK_FLAGS
	advapi32
	comctl32
	comdlg32
	gdi32
	imm32
	kernel32
	msimg32
	netapi32
	odbc32
	odbccp32
	ole32
	oleaut32
	rpcrt4
	shell32
	shlwapi
	user32
	uuid
	winmm
	winspool
	ws2_32
)

macro(link_with_windows _target)
	target_link_libraries(${_target} ${WINDOWS_LINK_FLAGS})
endmacro()
