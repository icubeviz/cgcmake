set(MSVC_COMPILER "2008" CACHE STRING "Visual Studio compiler selection")

set(ARCH "x64" CACHE STRING "Target architecture")

set(VRAY_VERSION "30" CACHE STRING "V-Ray version")

option(WITH_INSTALLED_VRAY  "Use installed V-Ray SDK" OFF)

option(WITH_CUSTOM_VRAY     "Use custom V-Ray SDK"    OFF)
option(WITH_CUSTOM_3DSMAX   "Use custom 3ds max SDK"  OFF)
option(WITH_CUSTOM_MAYA     "Use custom Maya SDK"     OFF)

option(WITH_LIBCPP          "Use libc++ (Apple)"      OFF)
