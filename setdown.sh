#! /bin/sh
#
# setdown - Étoilé 'unsetup' tool
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

tooldir="/usr/local/bin/"
libdir="/usr/lib/"

for toolname in opentool openapp debugapp defaults; do
    tool="$tooldir$toolname"
    if [ -x "$tool" ]; then
        echo "Removing $toolname in /usr/local/bin";
        rm $tool
    fi
done
echo

for libname in libgnustep-base.so; do
    lib="$libdir$libname"
    # FIXME: Pass the test for every strings expanded from $lib*
    if [ -x "$lib" ]; then
        echo "Removing $libname and related in /usr/lib";
        rm $lib*
    fi
done
echo

toolname=etoile_system
tool="$tooldir$toolname"

if [ -x "$tool" ]; then
    echo "Removing $toolname in /usr/local/bin";
    rm $tool;
    echo
fi

filename=etoile.desktop
filedir="/usr/share/xsessions/"
file="$filedir$filename"
if [ -f "$file" ]; then
    echo "Removing $filename in $filedir";
    rm $file;
    echo
fi
