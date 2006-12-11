#! /bin/sh
#
# setup - Étoilé setup tool
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

systemLevelSetup()
{
	
	#
	# Install essential GNUstep tools in a convenient way
	#
	
	gstooldir="$GNUSTEP_SYSTEM_ROOT/Tools"
	tooldir="/usr/local/bin"

	echo
	for toolname in opentool openapp debugapp defaults; do
		tool="$gstooldir/$toolname"
		if [ -x "$tool"  ]; then
			echo "Linking $toolname in $tooldir"
			#$(LN_S) $tool "/usr/local/bin/$toolname"
			$SUDO ln -s $tool "$tooldir/$toolname"
		fi
	done
	
	#
	# Install essential GNUstep libraries in a convenient way
	#

# FIXME: Turn on this code that set up the library paths with ldconfig and 
# should replace the code that symbolically links libraries in /usr/lib
#
# 	gslibsuffix=Library/Libraries
# 	gslibdirs="$GNUSTEP_SYSTEM_ROOT/$gslibsuffix $GNUSTEP_LOCAL_ROOT/$gslibsuffix $GNUSTEP_LOCAL_ROOT/$gslibsuffix"
# 	newlibdirs=
# 	if [ -x /etc/ld.so.conf ]; then
# 		for libdir in gslibdirs; do
# 			if [ -n grep "$libdir" /etc/ld.so.conf ]; then
# 				$newlibdirs=$newlibdirs\n$libdir
# 			fi
# 		done
# 	else
# 		newlibdirs="$GNUSTEP_SYSTEM_ROOT/$gslibsuffix\n$GNUSTEP_LOCAL_ROOT/$gslibsuffix\n$GNUSTEP_LOCAL_ROOT/$gslibsuffix"
# 	fi
# 	"$newlibdirs" > /etc/ld.so.conf
#
# 	$SUDO ldconfig

	gslibsuffix=Library/Libraries
	gslibdir="$GNUSTEP_SYSTEM_ROOT/$gslibsuffix"

	# NOTE: We should install in /usr/local/lib, then add /usr/local/lib 
	# to the library path search (by asking the right to the user)
	libdir="/usr/lib" 
	
	echo
	for libname in libgnustep-base.so libgnustep-gui.so libXWindowServerKit.so libWorkspaceCommKit.so; do
		lib="$gslibdir/$libname"
		# FIXME: Pass the test for every strings expanded from $lib*
		if [ -x "$lib" ]; then 
			echo "Linking $libname in $libdir"
			#$(LN_S) $lib "/usr/lib/libname"
			# FIXME: Bizarrely, it seems to be necessary to link 
			# libgnustep-base.so.X.X (the one with version number) so we use $lib*
			# and not just $lib
			$SUDO ln -s $lib* $libdir
		fi
	done
	
	#
	# Install Etoile system init daemon
	#
	
	# NOTE: Probably replace /usr/local/bin by /usr/bin for etoile_system
	# deployment

	toolname=etoile_system
	tool="$PWD/Services/Private/System/obj/$toolname"

	echo
	echo "Copying $toolname in $tooldir";

	# NOTE: 'obj' name  may change depending on the GNUstep setup.
	$SUDO cp $PWD/Services/Private/System/obj/etoile_system /usr/local/bin

	
	#
	# Install Etoile support files
	#

	filename=etoile.desktop
	file="$PWD/Services/Private/System/$filename"
	filedir="/usr/share/xsessions"

	echo
	echo "Copying $filename in $filedir";
	# TODO: /usr/share/xsessions could vary with the host system and the
	# display manager. This is the proper value for Ubutun Linux.
	# Possible common paths are,
	# with GDM:
	# /etc/dm/Sessions
	# /etc/X11/gdm/Sessions
	# /usr/X11R6/share/gnome/xsessions
	# with KDM:
	# /usr/share/apps/kdm/sessions 
	# /usr/local/share/apps/kdm/sessions
	# This path is set in the config file of the display manager located
	# in /etc/X11/xdm. The related entry name in the config file is 
	# usually SessionsDirs.
	$SUDO cp $file $filedir

}

userLevelSetup()
{
	#
	# Set up defaults for Camaelon and EtoileWildMenus
	#

	if [ $AS_ROOT = yes -o $HAVE_SUDO = yes ]; then
		bundledir="$GNUSTEP_SYSTEM_ROOT/Library/Bundles"
	else
		# When the script is run without sudo or root permissions, we 
		# can suppose the bundles have been installed in the user 
		# Library and not the System one.
		bundledir="$GNUSTEP_USER_ROOT/Library/Bundles"
	fi
	# NOTE: Replace any repeated '/' by a single one, otherwise defaults 
	# will complain about it by throwing an exception.
        # This occurs when GNUstep is installed with the prefix '/'
	bundledir=`echo $bundledir | tr -s '/'`

	echo
	echo "Going to set or reset some preferences/defaults"
	echo
	echo "Resetting GSAppKitUserBundles (in NSGlobalDomain)"

	defaults write NSGlobalDomain GSAppKitUserBundles "($bundledir/Camaelon.themeEngine, $bundledir/EtoileMenus.bundle, $bundledir/EtoileBehavior.bundle)"

	echo "Setting User Interface Theme to Nesedah (in Camaelon domain)"
	defaults write Camaelon Theme Nesedah

}

# Beginning of the script

if [ ! -d "$GNUSTEP_SYSTEM_ROOT" ]; then
    echo
    echo "Your GNUstep environment isn't set up correctly. To install Etoile, you must source GNUstep.sh or GNUstep.csh located in System/Library/Makefiles/GNUstep.sh"
    echo
    exit
fi


### The code below written by Adam Fedor has been picked from InstallGNUstep 
### script (r22806) located in 'startup' module of GNUstep project 
### <http://www.gnustep.org>. With some modifications.

#NOTE: Keep it it in sync with setdown.sh identical part

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
  echo
  echo NOTE: You are not logged in as root
  echo
  echo Etoile needs to be set up with root privileges. If you
  echo do not have root privileges, you can also set up Etoile if
  echo you have sudo access or you can set up it in your home
  echo directory. If you have no idea what any of this means, you
  echo "should choose option two (2) below (or quit (option q) and read "
  echo "your computer manual on installing programs as root)."
  echo
  echo "1) I have sudo access in order to setup Etoile on the whole system"
  echo "2) I want to setup Etoile in my home directory"
  echo "q) I want to quit and start over."
  echo
  echo $ECHO_N "Enter a number: $ECHO_C"
  read user_option
  case "$user_option" in
    1) if [ $HAVE_SUDO = no ]; then
         echo
         echo Cannot find sudo program. Make sure it is in your path
         echo
         exit 1
       fi;;
    2) gs_root_prefix=$HOME/GNUstep
       if [ -z "$GSCONFIGFILE" ]; then
         GSCONFIGFILE=--with-config-file=$gs_root_prefix/GNUstep.conf
       fi 
       NO_PRIV=yes
       HAVE_SUDO=no;;
    *) echo
       exit 0;;
  esac
else
  if [ $gs_run_batch = no ]; then
    if [ $AS_ROOT = yes -o $HAVE_SUDO = yes ]; then
      echo
      echo "Etoile environment will be set down in a system wide way since you are"
      echo "running this script with root privileges."
    fi
    echo
    echo $ECHO_N "Press the Return key to begin or 'q' to exit: $ECHO_C"
    read user_enter
    if [ "$user_enter" = q ]; then
      echo
      exit 0
    fi
  fi
fi

SUDO=
if [ $AS_ROOT = no -a $HAVE_SUDO = yes ]; then
  SUDO=sudo
  echo
  echo "*** You will be prompted for a sudo password during installation ***"
fi

### End of the code picked from InstallGNUstep

#
# When we have the right permissions, we handle the host system level set up
#

if [ $AS_ROOT = yes -o $HAVE_SUDO = yes ]; then
	systemLevelSetup
fi

#
# Stuff to be set up at System level when possible, otherwise at user level
#

if [ $AS_ROOT = yes -o $HAVE_SUDO = yes ]; then
    setupdir="$GNUSTEP_SYSTEM_ROOT/Library"
else
    setupdir="$GNUSTEP_USER_ROOT/Library"
    echo $SUDO
fi

echo
if [ ! -d "$setupdir/Etoile" ]; then 
	echo "Creating $setupdir/Etoile directory";
	$SUDO mkdir $setupdir/Etoile
fi
echo "Installing System support files in $setupdir/Etoile";
$SUDO cp -R $PWD/Services/Private/System/SystemTaskList.plist $setupdir/Etoile

echo
echo "Copying Themes in $setupdir/Themes";
# FIXME: Strip .svn with find . \! -path "*\.svn*"
$SUDO cp -R $PWD/Themes $setupdir

#
# We end by setting user related stuff which are mandatory to hava a working
# Etoile environment
#

userLevelSetup

echo

# End of the script
