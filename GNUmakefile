#
#	GNUmakefile
#
#	Makefile for Etoile
#
#	Copyright (C) 2005 Quentin Mathe <qmathe@club-internet.fr>
#
#	This Makefile is free software; you can redistribute it and/or
#	modify it under the terms of the GNU General Public License
#	as published by the Free Software Foundation; either version 2
#	of the License, or (at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
#	See the GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program; if not, write to:
#
#		Free Software Foundation, Inc.
#		59 Temple Place - Suite 330
#		Boston, MA  02111-1307, USA
#

# When pmk will work :
# Template file !
# Use pmkfile first !

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
    export workspace ?= no

endif

ifeq ($(etoile), yes)

    #
    # "make etoile=yes" is the verbose equivalent for "make"
    #

    export desktop-base ?= yes
    export user-base ?= yes
    export etoile-extensions ?= yes
    export workspace ?= yes
    
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
    
endif

ifeq ($(user-base), yes)

    export installer ?= yes
    
endif

#
# Subprojects choice
#

SUBPROJECTS = Frameworks Bundles Services #Documentation

include $(GNUSTEP_MAKEFILES)/aggregate.make
