include $(GNUSTEP_MAKEFILES)/common.make

#
# Variables to turn projects on and off in the build process
# (listed by alphabetical order)
#

-include ../modules.make

export etoilefoundation ?= yes
export unitkit ?= yes

#
# Projects (listed by dependency order, then alphabetical order)
#

# We need to build UnitKit first because other frameworks may depend on it 
# (the whole repository may build with 'make test=yes').
ifeq ($(unitkit), yes)
   SUBPROJECTS += UnitKit 
endif

ifeq ($(etoilefoundation), yes)
    SUBPROJECTS += EtoileFoundation
endif

include $(GNUSTEP_MAKEFILES)/aggregate.make
