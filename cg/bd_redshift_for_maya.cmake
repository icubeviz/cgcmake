#
# Build system based on CMake
#
# Andrei Izrantcev <izrantsev@rendering.ru>
#
# Copyright (c) iCube R&D Group, www.icube3d.com
#
# These coded instructions, statements, and computer programs contain
# unpublished proprietary information written by iCube R&D Group.
# They may not be disclosed to third parties or copied or duplicated in
# any form, in whole or in part, without the prior written consent of
# iCube R&D Group.
#

function(bd_redshift_maya_setup _target)
	set(REDSHIFT_SDK ${SDK_ROOT}/redshift/${REDSHIFT_VERSION})
	set(REDSHIFT_LIBS redshift-core-vc100)

	target_include_directories(${_target} PRIVATE ${REDSHIFT_SDK}/include)
	target_link_directories(${_target}    PRIVATE ${REDSHIFT_SDK}/lib/${OS})
	target_link_libraries(${_target}      PRIVATE ${REDSHIFT_LIBS})
endfunction()
