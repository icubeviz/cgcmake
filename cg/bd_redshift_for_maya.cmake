#
# Build system based on CMake
#
# Andrei Izrantcev <izrantsev@rendering.ru>
#
# Copyright (c) iCube R&D Group, www.rendering.ru
#
# These coded instructions, statements, and computer programs contain
# unpublished proprietary information written by iCube R&D Group.
# They may not be disclosed to third parties or copied or duplicated in
# any form, in whole or in part, without the prior written consent of
# iCube R&D Group.
#

function(bd_redshift_for_maya_setup_target _target)
	target_include_directories(${_target}
		PRIVATE
			${SDK_ROOT}/redshift/${REDSHIFT_VERSION}/include
	)

	target_link_directories(${_target}
		PRIVATE
			${SDK_ROOT}/redshift/${REDSHIFT_VERSION}/lib/${OS}
	)

	target_link_libraries(${_target}
		redshift-core-vc100
	)
endfunction()
