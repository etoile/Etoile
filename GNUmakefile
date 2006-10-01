include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = Etoile

#
# Variables check
#

export etoile ?= yes

ifeq ($(etoile), no)

    export desktop-base ?= yes
    export developer-base ?= yes
    export etoile-extensions ?= no
    export user-base ?= no
    export workspace ?= no

endif

ifeq ($(etoile), yes)

    #
    # "make etoile=yes" is the verbose equivalent for "make" except it doesn't
    # include developer stuff.
    #

    export desktop-base ?= yes
    export etoile-extensions ?= yes
    export user-base ?= yes
    export workspace ?= yes
    export developer-base ?= no
    
endif 

ifeq ($(desktop-base), yes)

    export bookmarkkit ?= yes
    export iconkit ?= yes
    export preferenceskit ?= yes
    export camaelon ?= yes
    
endif

ifeq ($(etoile-extensions), yes)

    export extendedworkspacekit ?= yes
    export lucenekit ?= yes
    export servicesbarkit ?= yes
    export trackerkit ?= yes
    export servicesbar ?= yes
    
endif

ifeq ($(developer-base), yes)

    export unitkit ?= yes
    export unittests ?= yes
    export examples ?= yes
    
endif

ifeq ($(test), yes)

    export unitkit ?= yes
    export unittests ?= yes
    export examples ?= yes
    
endif

ifeq ($(user-base), yes)

    export installer ?= yes
    
endif

#
# Subprojects choice
#

SUBPROJECTS = Languages Frameworks Bundles Services Developer #Documentation

include $(GNUSTEP_MAKEFILES)/aggregate.make
