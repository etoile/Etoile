PACKAGE_NAME = Developer

include $(GNUSTEP_MAKEFILES)/common.make

#
# Variables check
#

export etoile ?= yes
export developer-base ?= yes

#
# Subprojects choice
#

ifeq ($(developer-base), yes)
	SUBPROJECTS = Services
endif

include $(GNUSTEP_MAKEFILES)/aggregate.make
