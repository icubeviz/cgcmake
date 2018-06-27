#
# Copyright (c) Chaos Software Ltd
#
# All rights reserved. These coded instructions, statements and
# computer programs contain unpublished information proprietary to
# Chaos Software Ltd, which is protected by the appropriate copyright
# laws and may not be disclosed to third parties or copied or
# duplicated, in whole or in part, without prior written consent of
# Chaos Software Ltd.
#

execute_process(
	COMMAND
		${WITH_APPIMAGE} ${PROJECT_NAME}.desktop -qmake=${WITH_QT_ROOT}/bin/qmake -appimage -no-translations
	WORKING_DIRECTORY
		${CMAKE_INSTALL_PREFIX}
)
