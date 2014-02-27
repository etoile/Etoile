include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = DeveloperServices

#
# Projects (listed by dependency order, then alphabetical order)
#

export docgenerator ?= yes
export unittests ?= no

#
# Projects (listed by dependency order, then alphabetical order)
#

ifeq ($(docgenerator), yes)
	SUBPROJECTS = DocGenerator
endif

ifeq ($(unittests), yes)
	SUBPROJECTS = UnitTests
endif

include $(GNUSTEP_MAKEFILES)/aggregate.make
