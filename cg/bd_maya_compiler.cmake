#
# Build system based on CMake
#
# Copyright (c) iCube R&D Group, www.rendering.ru
#
# These coded instructions, statements, and computer programs contain
# unpublished proprietary information written by iCube R&D Group.
# They may not be disclosed to third parties or copied or duplicated in
# any form, in whole or in part, without the prior written consent of
# iCube R&D Group.
#
set(MAYA_VERSION "2016" CACHE STRING "Maya version")

if(MAYA_VERSION STREQUAL 2009)
	set(MSVC_COMPILER 2005)
elseif(MAYA_VERSION STREQUAL 2010)
	set(MSVC_COMPILER 2008)
elseif(MAYA_VERSION STREQUAL 2011)
	set(MSVC_COMPILER 2008)
elseif(MAYA_VERSION STREQUAL 2012)
	set(MSVC_COMPILER 2008)
elseif(MAYA_VERSION STREQUAL 2013)
	set(MSVC_COMPILER 2010)
elseif(MAYA_VERSION STREQUAL 2013.5)
	set(MSVC_COMPILER 2010)
elseif(MAYA_VERSION STREQUAL 2014)
	set(MSVC_COMPILER 2010)
elseif(MAYA_VERSION STREQUAL 2015)
	set(MSVC_COMPILER 2012)
elseif(MAYA_VERSION STREQUAL 2016)
	set(MSVC_COMPILER 2012)
elseif(MAYA_VERSION STREQUAL 2016.5)
	set(MSVC_COMPILER 2012)
elseif(MAYA_VERSION STREQUAL 2017)
	set(MSVC_COMPILER 2012)
elseif(MAYA_VERSION STREQUAL 2018)
	set(MSVC_COMPILER 2015)
elseif(MAYA_VERSION VERSION_GREATER_EQUAL 2019)
	set(MSVC_COMPILER 2017)
endif()
