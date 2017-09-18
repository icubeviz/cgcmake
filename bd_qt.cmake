set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)

if(WIN32)
	SET(QT_USE_QTGUI TRUE)
	SET(QT_USE_QTMAIN TRUE)
	SET(QT_USE_QTPLUGIN TRUE)
	set(QT_ROOT "${SDK_ROOT}/qt/windows/5.6.1/vc14/x86")
else()
	set(QT_ROOT "${SDK_ROOT}/qt/linux/5.6.1")
endif()

set(QT_LIB "${QT_ROOT}/lib")

set(CMAKE_PREFIX_PATH "${QT_ROOT}")

add_definitions(
	-DQT_STATICPLUGIN
	-DQT_NODLL
	-DSTATIC
)

link_directories("${QT_ROOT}/plugins/platforms")

if(WIN32)
elseif(APPLE)
else()
	# WHY?
	link_directories("/home/bdancer/build/qt-everywhere-opensource-src-5.2.1/qtbase/src/plugins/platforms/xcb/xcb-static")

	add_definitions(
		-DLINUX
		-D_REENTRANT
	)
endif()
