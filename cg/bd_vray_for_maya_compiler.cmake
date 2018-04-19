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

if(MAYA_VERSION VERSION_GREATER_EQUAL 2018)
	if(VRAY_VERSION VERSION_GREATER_EQUAL 40)
		set(MSVC_COMPILER 2017)
	endif()
endif()
