#! /bin/sh
#
# setdown - Étoilé 'unsetup' tool
#
# Copyright (C) 2006 Free Software Foundation, Inc.
#
# Authors: Quentin Mathe <qmathe@club-internet.fr>
#          Adam Fedor <fedor@gnu.org> (InstallGNUstep code)
# Date: May 2006
# 
# This file is part of the Etoile environment.
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

#
# Function used by the script implemented below
#

userLevelSetdown()
{
	#
	# Unset defaults for Camaelon and EtoileWildMenus
	#
	
	bundledir="$GNUSTEP_SYSTEM_ROOT/Library/Bundles/"
	
	echo "Going to unset some preferences/defaults"
    echo
	echo "Unsetting GSAppKitUserBundles (in NSGlobalDomain)"
	defaults write NSGlobalDomain GSAppKitUserBundles "()"

	echo "Unsetting User Interface Theme (in Camaelon domain)"
	defaults write Camaelon Theme ""

	echo
}

systemLevelSetdown()
{
	tooldir="/usr/local/bin/"
	libdir="/usr/lib/"
	
	for toolname in opentool openapp debugapp defaults; do
		tool="$tooldir$toolname"
		if [ -x "$tool" ]; then
			echo "Removing $toolname in /usr/local/bin";
			$SUDO rm $tool
		fi
	done
	echo
	
	for libname in libgnustep-base.so; do
		lib="$libdir$libname"
		# FIXME: Pass the test for every strings expanded from $lib*
		if [ -x "$lib" ]; then
			echo "Removing $libname and related in /usr/lib";
			$SUDO rm $lib*
		fi
	done
	echo
	
	toolname=etoile_system
	tool="$tooldir$toolname"
	
	if [ -x "$tool" ]; then
		echo "Removing $toolname in /usr/local/bin";
		$SUDO rm $tool;
		echo
	fi
	
	filename=etoile.desktop
	filedir="/usr/share/xsessions/"
	file="$filedir$filename"
	if [ -f "$file" ]; then
		echo "Removing $filename in $filedir";
		$SUDO rm $file;
		echo
	fi
}

# Beginning of the script

echo

### The code below written by Adam Fedor has been picked from InstallGNUstep 
### script (r22806) located in 'startup' module of GNUstep project 
### <http://www.gnustep.org>. With some modifications.

# NOTE: Keep it it in sync with setup.sh identical part

gs_run_batch=no
gs_no_priv=no

#--------------------------------------------------------------------
# Check how we can install. If we are running as root, just go
# ahead. Otherwise ask the user if they can install via sudo or if
# they just want to try it in their home directory.
#--------------------------------------------------------------------

HAVE_SUDO=no
NO_PRIV=$gs_no_priv
WHOAMI=none
which whoami 2>&1 > /dev/null
if [ $? = 0 ]; then
  WHOAMI=`whoami`
elif [ -f /usr/ucb/whoami ]; then
  WHOAMI=`/usr/ucb/whoami`
else
  WHOAMI=`who am i | awk '{print $1}'`
fi
which sudo > /dev/null
if [ $? = 0 ]; then
  HAVE_SUDO=yes
fi
if [ "$GS_PLATFORM_NO_ROOT" = yes ]; then
  # Typically on mingw, cygwin
  WHOAMI=root
fi
AS_ROOT=yes
# If we are running in batch mode, just assume that the user has install
# privileges (i.e. assume they know what they are doing).
if [ "$WHOAMI" != root -a $gs_run_batch = no ]; then
  AS_ROOT=no
  echo NOTE: You are not logged in as root
  echo
  echo If Etoile is set up on the whole system, you need root privileges to set
  echo it down. If you do not have root privileges or sudo access, you cannot 
  echo set down Etoile in a system wide way.
  echo But if Etoile is set up in your home directory, you don\'t need anything 
  echo special to set it down.
  echo If you have no idea what any of this means,
  echo "you should choose option two (2) below (or quit (option q) and read "
  echo "your computer manual on uninstalling programs as root)."
  echo
  echo "1) Etoile is set up in a system wide way, I have sudo access and I "
  echo "   want to set it down"
  echo "2) Etoile is set up my home directory and I want to set it down"
  echo "q) I want to quit and start over."
  echo
  echo $ECHO_N "Enter a number: $ECHO_C"
  read user_option
  case "$user_option" in
    1) if [ $HAVE_SUDO = no ]; then
         echo Cannot find sudo program. Make sure it is in your path
         exit 1
       fi;;
    2) gs_root_prefix=$HOME/GNUstep
       if [ -z "$GSCONFIGFILE" ]; then
         GSCONFIGFILE=--with-config-file=$gs_root_prefix/GNUstep.conf
       fi 
       NO_PRIV=yes
       HAVE_SUDO=no;;
    *) exit 0;;
  esac
else
  if [ $gs_run_batch = no ]; then
    echo $ECHO_N "Press the Return key to begin continue: $ECHO_C"
    read user_enter
    if [ "$user_enter" = q ]; then
      exit 0
    fi
  fi
fi

SUDO=
if [ $AS_ROOT = no -a $HAVE_SUDO = yes ]; then
  SUDO=sudo
  echo
  echo "*** You will be prompted for a sudo password during uninstallation ***"
  echo
fi

### End of the code picked from InstallGNUstep

#
# We start by unsetting user related stuff
#

userLevelSetdown

#
# Stuff to be unset et System level when possible, otherwise at user level
#

if [ $AS_ROOT = yes -o $HAVE_SUDO = yes ]; then
    setupdir="$GNUSTEP_SYSTEM_ROOT/Library"
else
    setupdir="$GNUSTEP_USER_ROOT/Library"
fi
echo "Removing Themes in $setupdir/Themes";
$SUDO rm -rf $setupdir/Themes
echo

#
# When we have the right permissions, we handle the host system level set down
#

if [ $AS_ROOT = yes -o $HAVE_SUDO = yes ]; then
	systemLevelSetdown
fi

# End of the script
