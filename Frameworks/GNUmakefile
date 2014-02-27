include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = Frameworks

#
# Variables to turn projects on and off in the build process
# (listed by alphabetical order)
#

-include ../modules.make

export addresseskit ?= no
export bookmarkkit ?= no
export coreobject ?= yes
export etoilefoundation ?= yes
export etoileui ?= yes
export etoileserialize ?= no
export iconkit ?= yes
export mediakit ?= no
export ogrekit ?= no
export opmlkit ?= no
export panekit ?= no
export popplerkit ?= no
export scriptkit ?= yes
export unitkit ?= yes
export rsskit ?= no
export menukit ?= no
export systemconfig ?= yes
export xmppkit ?= no
export xwindowserverkit ?= no

#
# Projects (listed by dependency order, then alphabetical order)
#

# We need to build UnitKit first because other frameworks may depend on it 
# (the whole repository may build with 'make test=yes').
ifeq ($(unitkit), yes)
   SUBPROJECTS += UnitKit 
endif

# We need to build EtoileFoundation, EtoileSerialize, CoreObject and EtoileUI 
# first because  most other frameworks depends on it.

ifeq ($(objc-2), yes)
    SUBPROJECTS += ObjectiveC2
endif

ifeq ($(etoilefoundation), yes)
    SUBPROJECTS += EtoileFoundation
endif

ifeq ($(etoileserialize), yes)
    SUBPROJECTS += EtoileSerialize
endif

ifeq ($(coreobject), yes)
    SUBPROJECTS += CoreObject
endif

ifeq ($(iconkit), yes)
   SUBPROJECTS += IconKit
endif

# Depends on CoreObject and IconKit
ifeq ($(etoileui), yes)
    SUBPROJECTS += EtoileUI
endif

# Will depend on CoreObject
ifeq ($(bookmarkkit), yes)
    SUBPROJECTS += BookmarkKit
endif

# Will depend on CoreObject
ifeq ($(addresseskit), yes)
   SUBPROJECTS += AddressesKit
endif

ifeq ($(ogrekit), yes)
   SUBPROJECTS += OgreKit
endif

ifeq ($(systemconfig), yes)
   SUBPROJECTS += SystemConfig
endif

# Depends on SystemConfig
ifeq ($(mediakit), yes)
   SUBPROJECTS += MediaKit
endif

ifeq ($(opmlkit), yes)
   SUBPROJECTS += OPMLKit
endif

ifeq ($(panekit), yes)
   SUBPROJECTS += PaneKit
endif

ifeq ($(popplerkit), yes)
   SUBPROJECTS += PopplerKit
endif

ifeq ($(rsskit), yes)
   SUBPROJECTS += RSSKit
endif

ifeq ($(scriptkit), yes)
   SUBPROJECTS += ScriptKit
endif

ifeq ($(menukit), yes)
  ifneq ($(FOUNDATION_LIB), apple)
    # Do not compile for apple
    SUBPROJECTS += MenuKit
  endif
endif

# Depends on AddressBook
ifeq ($(xmppkit), yes)
   SUBPROJECTS += XMPPKit
endif

ifeq ($(xwindowserverkit), yes)
   SUBPROJECTS += XWindowServerKit
endif

include $(GNUSTEP_MAKEFILES)/aggregate.make
