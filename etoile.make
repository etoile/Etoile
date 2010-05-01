#
# Etoile Makefile Extensions (dependency support, test support, etc.)
#

# NOTE: In this file, 'module' and 'project' words have exactly the same 
# meaning.

# This variable can be used to check in a GNUmakefile whether a module is 
# built as a part of Etoile or not. 
export etoile = yes

### Linking Variables ###

# You can link all the core frameworks with the single flag ETOILE_CORE_LIBS and 
# Smalltalk dependencies with SMALLTALK_LIBS. .
# Pass these flags to xxx_LIBRARIES_DEPEND_UPON for a framework/library, and to 
# xxx_GUI_LIBS, xxx_TOOL_LIBS or xxx_BUNDLE_LIBS for other targets (applications,
# tools and bundles).

ETOILE_FOUNDATION_LIBS = -lEtoileFoundation -lEtoileThread -lEtoileXML
COREOBJECT_LIBS = -lCoreObject -lEtoileSerialize
ETOILE_UI_LIBS = -lEtoileUI

export ETOILE_CORE_LIBS = $(ETOILE_FOUNDATION_LIBS) $(COREOBJECT_LIBS) $(ETOILE_UI_LIBS) 
export SMALLTALK_LIBS = -lEtoileFoundation -lLanguageKit -lSmalltalkSupport

### Installation Control ###

ifeq ($(ETOILE_CORE_MODULE), YES)
  export GNUSTEP_INSTALLATION_DOMAIN = SYSTEM
endif

### Internal Dependency Handling ###

# CURDIR is the path where make is run, with gnustep-make the value changes in
# subdirectories since each 'submake' is a 'normal' make, sandboxed and not 
# run recursively from the initial directory.
#
# PROJECT_DIR is the path where make is invoked, the first directory where 
# make is run, this variable allows to keep a reference to the initial 
# directory taking in account the previous comment about CURDIR.
#
# PROJECT_NAME is the name of the module to be built, by default the last path 
# path component of PROJECT_DIR is used as name. It must match the module 
# target variable like FRAMEWORK_NAME, APP_NAME etc. If you use a target name 
# which is unrelated to the last path component of PROJECT_DIR, you must 
# redefine this variable in your GNUmakefile.
#
# PWD or ./ is the path where the current makefile is located (for 
# etoile.make, this is always Etoile/)

export PROJECT_DIR ?= $(CURDIR)

PROJECT_NAME ?= $(notdir $(PROJECT_DIR))

# We search etoile.make path in the repository... because Make doesn't provide 
# any variables to obtain included makefile paths.
prefix = $(if $1,\
             $(if $(wildcard $1/etoile.make),\
                 $(dir \
                     $(wildcard $1/etoile.make)),\
                 $(call prefix,\
                     $(patsubst %/$(notdir $1),%, $1))),\
             $(warning No makefile etoile.make found in the repository tree.))

PREFIX = $(patsubst %/,%,$(call prefix,$(PROJECT_DIR)))

BUILD_DIR = $(PREFIX)/Build

# We create a temporary header directory to support #import <PROJECT_NAME/header.h>
# from within the library/framework project itself.
define create-local-header-dir
  if [ ! -L $(PROJECT_DIR)/$(PROJECT_NAME) ]; then \
    if [ -d $(PROJECT_DIR)/Headers ]; then \
      $(LN_S) $(PROJECT_DIR)/Headers $(PROJECT_DIR)/$(PROJECT_NAME); \
    elif [ -n "$(LIBRARY_NAME)" -o -n "$(FRAMEWORK_NAME)" ]; then \
      $(LN_S) $(PROJECT_DIR) $(PROJECT_DIR)/$(PROJECT_NAME); \
    fi; \
  fi;
endef 

before-all::
	$(ECHO_NOTHING) \
	echo ""; \
	echo "Build Project: $(PROJECT_NAME)"; \
	echo ""; \
	$(create-local-header-dir) \
	if [ ! -d $(BUILD_DIR) ]; then \
	  mkdir $(BUILD_DIR); \
	fi; \
	$(END_ECHO)

define check-variables
  if [ -z $(PROJECT_DIR) ]; then \
    echo "Dependency export failed: PROJECT_DIR is not set"; \
    echo ""; \
    exit; \
  fi; \
  if [ -z $(PROJECT_NAME) ]; then \
    echo "Dependency export failed: PROJECT_NAME is not set"; \
    echo ""; \
    exit; \
  fi; \
  if [ -z $(PREFIX) ]; then \
    echo "Dependency export failed: PREFIX is not set"; \
    echo ""; \
    exit; \
  fi;
endef

# For a framework target, we create a symbolic link inside Build for the 
# framewrok itself inside but also a symbolic link libFrameworkName.so pointing on 
# frameworkName.framework/Versions/Current/libFrameworkName.so
# TODO: Would be nice if gnustep-make could discover the library file by itself.
#
# NOTE: sh seems to have trouble to interpolate $() unlike ${} in the following case:
# for libfile in ${PROJECT_DIR}/${PROJECT_NAME}.framework/Versions/Current/lib${PROJECT_NAME}${SHARED_LIBEXT}*; do 
#   $(LN_S) -f $$libfile $(BUILD_DIR); 
# done 
define export-framework
  if [ -d  $(PROJECT_DIR)/$(PROJECT_NAME).framework ]; then \
    exported="yes"; \
    $(LN_S) -f $(PROJECT_DIR)/$(PROJECT_NAME).framework $(BUILD_DIR)/$(PROJECT_NAME).framework; \
    $(LN_S) -f ${PROJECT_DIR}/${PROJECT_NAME}.framework/Versions/Current/${GNUSTEP_TARGET_LDIR}/lib${PROJECT_NAME}${SHARED_LIBEXT}* $(BUILD_DIR); \
  fi;
endef

define export-library-files
  if [ -f $(PROJECT_DIR)/obj/${GNUSTEP_TARGET_LDIR}/lib$(PROJECT_NAME)$(SHARED_LIBEXT) ]; then \
    exported="yes"; \
    $(LN_S) -f ${PROJECT_DIR}/obj/${GNUSTEP_TARGET_LDIR}/lib${PROJECT_NAME}${SHARED_LIBEXT}* $(BUILD_DIR); \
  fi; \
  \
  if [ -f $(PROJECT_DIR)/Source/obj/${GNUSTEP_TARGET_LDIR}/lib$(PROJECT_NAME)$(SHARED_LIBEXT) ]; then \
    exported="yes"; \
    $(LN_S) -f ${PROJECT_DIR}/Source/obj/${GNUSTEP_TARGET_LDIR}/lib${PROJECT_NAME}${SHARED_LIBEXT}* $(BUILD_DIR); \
  fi;
endef

# We use 'exported' variable in the after-all script to remember we detected a 
# framework or a library in a module and we have to export the related headers.
define export-headers
  if [ "$${exported}" = "yes" ]; then \
    if [ -d $(PROJECT_DIR)/Headers -a ! -L $(BUILD_DIR)/$(PROJECT_NAME) ]; then \
      $(LN_S) $(PROJECT_DIR)/Headers $(BUILD_DIR)/$(PROJECT_NAME); \
    elif [ ! -L $(BUILD_DIR)/$(PROJECT_NAME) ]; then \
      $(LN_S) $(PROJECT_DIR) $(BUILD_DIR)/$(PROJECT_NAME); \
    fi; \
  fi;
endef

# To debug, insert the next line close to the beginning of after-all.
#echo "etoile.make: PROJECT_DIR $(PROJECT_DIR) PROJECT_NAME $(PROJECT_NAME) BUILD_DIR $(BUILD_DIR)"; \
# For debug, insert the next line close to the end of after-all.
#echo "$(PROJECT_DIR) $(BUILD_DIR) $(PROJECT_NAME)"; \
#
# NOTE: Don't put these statements commented out directly in the code because
# it could make the build fails on some platforms as explained in bug report #8484
after-all::
	$(ECHO_NOTHING) \
	$(check-variables) \
	$(export-framework) \
	$(export-library-files) \
	$(export-headers) \
	$(END_ECHO)

define remove-local-header-dir
  if [ -L $(PROJECT_DIR)/$(PROJECT_NAME) ]; then \
    rm -f $(PROJECT_DIR)/$(PROJECT_NAME); \
  fi;
endef

define remove-exported-headers
  if [ -L $(BUILD_DIR)/$(PROJECT_NAME) ]; then \
    rm -f $(BUILD_DIR)/$(PROJECT_NAME); \
    removed="yes"; \
  fi;
endef

define remove-exported-library-files
  if [ -L $(BUILD_DIR)/lib$(PROJECT_NAME)$(SHARED_LIBEXT) ]; then \
    rm -f $(BUILD_DIR)/lib$(PROJECT_NAME)$(SHARED_LIBEXT)*; \
    removed="yes"; \
  fi;
endef

define remove-exported-framework
  if [ -L $(BUILD_DIR)/$(PROJECT_NAME).framework ]; then \
    rm -f $(BUILD_DIR)/$(PROJECT_NAME).framework; \
    removed="yes"; \
  fi;
endef

after-clean::
	$(ECHO_NOTHING) \
	echo ""; \
	$(check-variables) \
	$(remove-local-header-dir) \
	$(remove-exported-headers) \
	$(remove-exported-library-files) \
	$(remove-exported-framework) \
	if [ "$${removed}" = "yes" ]; then \
	echo " Removed $(PROJECT_NAME) dependency export"; \
	echo ""; \
	fi; \
	$(END_ECHO)

after-distclean:: after-clean


### Default Variable Values For Conveniency ###

# You can overidde any variable values defined by below by resetting the value
# in the GNUmakefile.preamble of your module. For example:
# unexport ADDITIONAL_INCLUDE_DIRS = 
# If you don't put 'unexport' in front of the variable name, the variable will
# be reset but still exported to submake instances (this is never the case with
# gnustep-make variables, that's why you should include a GNUmakefile.preamble 
# in any subdirectories of your module usually).

# If we have dependency, once it's imported we need to include its headers
# located PROJECT_DIR/PROJECT_NAME. This means we have to look in 
# PROJECT_DIR since we usually use include directive like 
# #import <PROJECT_NAME/header.h>
#
# By default we also look for headers in PROJECT_DIR and PROJECT_DIR/Headers, 
# this conveniency avoids to take care of such flags over and over.
export ADDITIONAL_INCLUDE_DIRS += -I$(BUILD_DIR) -I$(PROJECT_DIR) -I$(PROJECT_DIR)/Headers 

# For Clang, see http://llvm.org/bugs/show_bug.cgi?id=7005
export ADDITIONAL_INCLUDE_DIRS += -I/usr/include/`gcc -dumpmachine`/

# If we have dependency, we need to link its resulting object file. Well, we
# have to look for a library or a framework most of time.
#
# NOTE: We cannot use $(GNUSTEP_SHARED_OBJ) instead of shared_obj because the 
# former variable is relative to the project and could be modified by the 
# developer. For example, it's commonly equals to ./shared_obj
export ADDITIONAL_LIB_DIRS += -L$(BUILD_DIR)

# To resolve library files that are linked by other library files, but whose 
# symbols aren't referenced by the current project/target and hence not 
# explicitly linked. 
# For example, if you use EtoileFoundation that links to EtoileXML but you don't 
# reference any EtoileXML symbols and doesn't link it. In this last case without 
# a custom LD_LIBRARY_PATH or -rpath-link, a warning would be logged:
# /usr/bin/ld: warning: libEtoileXML.so.0, needed by /testEtoile/Build/libEtoileFoundation.so, not found (try using -rpath or -rpath-link)
# If -rpath-link is used, it overrides the search paths for shared libraries, so 
# only installed static libraries are visible to the linker, but not the shared 
# ones. That's why to allow the linking of shared libraries that are located 
# outside of BUILD_DIR, '-rpath-link $(BUILD_DIR)' is not enough and 
# LD_LIBRARY_PATH value has to be appended.
# Unlike shared libraries installed in standard locations such as /usr/lib, 
# GNUstep libraries doesn't seem to be affected by -rpath-link, not sure why... 
# Perhaps because gnustep-make is bypassing it for GNUstep install paths or core 
# libraries in one way or another.
# We use LD_LIBRARY_PATH by default, since it is known to work well on various 
# platforms.
#export ADDITIONAL_LDFLAGS += -Wl,-rpath-link $(BUILD_DIR):$(LD_LIBRARY_PATH)
export LD_LIBRARY_PATH := $(BUILD_DIR):$(LD_LIBRARY_PATH)

# We disable warnings about #import being deprecated. They occur with old GCC
# version (before 4.0 iirc).
export ADDITIONAL_OBJCFLAGS += -Wno-import -Werror -Wno-unused -Wno-implicit

# Ugly hack until gnustep-make is improved to export a variable that lets us know 
# which libobjc version we compile against.
# If a libobjc.so.4 (v2) is installed in a path listed below, but you use another 
# runtime you can force EtoileFoundation to use an older libobjc by exporting 
# the used runtime version in your shell first. e.g. 
# export GNU_RUNTIME_VERSION=1 && make clean && make
ifndef GNU_RUNTIME_VERSION
LIBOBJC = libobjc.so.4
GNU_RUNTIME_VERSION = 1
GNU_RUNTIME_VERSION := $(if $(wildcard $(GNUSTEP_SYSTEM_ROOT)/Library/Libraries/$(GNUSTEP_TARGET_LDIR)/$(LIBOBJC)),2,$(GNU_RUNTIME_VERSION))
GNU_RUNTIME_VERSION := $(if $(wildcard $(GNUSTEP_LOCAL_ROOT)/Library/Libraries/$(GNUSTEP_TARGET_LDIR)/$(LIBOBJC)),2,$(GNU_RUNTIME_VERSION))
GNU_RUNTIME_VERSION := $(if $(wildcard $(GNUSTEP_USER_ROOT)/Library/Libraries/$(GNUSTEP_TARGET_LDIR)/$(LIBOBJC)),2,$(GNU_RUNTIME_VERSION))
GNU_RUNTIME_VERSION := $(if $(wildcard /usr/lib/$(LIBOBJC)),2,$(GNU_RUNTIME_VERSION))
GNU_RUNTIME_VERSION := $(if $(wildcard /usr/local/lib/$(LIBOBJC)),2,$(GNU_RUNTIME_VERSION))
endif

export GNU_RUNTIME_VERSION
export ADDITIONAL_CPPFLAGS += -DGNU_RUNTIME_VERSION=$(GNU_RUNTIME_VERSION)

# For test bundles, we must link UnitKit
ifeq ($(test), yes)
  ifeq ($(FOUNDATION_LIB), apple)
    export ADDITIONAL_OBJC_LIBS += -framework UnitKit
  else
    export ADDITIONAL_OBJC_LIBS += -lUnitKit
  endif
endif
