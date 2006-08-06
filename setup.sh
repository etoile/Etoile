#! /bin/sh
#
# setup - Étoilé setup tool
#
# Copyright (C) 2006 Free Software Foundation, Inc.
#
# Author: Quentin Mathe <qmathe@club-internet.fr>
# Date: May 2006
# 
# This file is part of the GNUstep Makefile Package.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# You should have received a copy of the GNU General Public
# License along with this library; see the file COPYING.LIB.
# If not, write to the Free Software Foundation,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

echo

if [ ! -d "$GNUSTEP_SYSTEM_ROOT" ]; then
    echo "Your GNUstep environment isn't set up correctly. To install Etoile, you must source GNUstep.sh or GNUstep.csh located in System/Library/Makefiles/GNUstep.sh"
    echo
    exit
fi

#
# Install essential GNUstep tools in a convenient way
#

tooldir="$GNUSTEP_SYSTEM_ROOT/Tools/"

for toolname in opentool openapp debugapp defaults; do
    tool="$tooldir$toolname"
    if [ -x "$tool" ]; then
        echo "Linking $toolname in /usr/local/bin"
        #$(LN_S) $tool "/usr/local/bin/$toolname"
        ln -s $tool "/usr/local/bin/$toolname"
    fi
done
echo

#
# Install essential GNUstep libraries in a convenient way
#

libdir="$GNUSTEP_SYSTEM_ROOT/Library/Libraries/"

for libname in libgnustep-base.so; do
    lib="$libdir$libname"
    # FIXME: Pass the test for every strings expanded from $lib*
    if [ -x "$lib" ]; then 
        echo "Linking $libname in /usr/lib"
        #$(LN_S) $lib "/usr/lib/libname"
        # FIXME: Bizarrely, it seems to be necessary to link 
        # libgnustep-base.so.X.X (the one with version number) so we use $lib*
        # and not just $lib
        ln -s $lib* "/usr/lib/"
    fi
done
echo

#
# Install Etoile system init daemon
#

# NOTE: Probably replace /usr/local/bin by /usr/bin for etoile_system
# deployment
echo "Copying etoile_system in /usr/local/bin";
# FIXME: 'shared_obj' name  may change depending on the GNUstep setup.
cp $PWD/Services/Private/System/shared_obj/etoile_system /usr/local/bin
echo

#
# Install Etoile support files
#

echo "Copying etoile.desktop in /usr/share/xsessions";
# TODO: /usr/share/xsessions is surely varying with the host system
# This is the proper value for Ubutun Linux.
cp $PWD/Services/Private/System/etoile.desktop /usr/share/xsessions
echo
