#
# Etoile Makefile Extensions (dependency support, test support, etc.)
#

# NOTE: In this file, 'module' and 'project' words have exactly the same 
# meaning.

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

# Finally we search etoile.make path in the repository... because Make doesn't 
# provide any variables to obtain included makefile paths (well, I would like
# to be wrong on this one).

prefix = $(if $1,\
             $(if $(shell find $1 -maxdepth 1 -name etoile.make),\
                 $(dir \
                     $(shell find $1 -maxdepth 1 -name etoile.make)),\
                 $(call prefix,\
                     $(patsubst %/$(notdir $1),%, $1))),\
             $(warning No makefile etoile.make found in the repository tree.))

PREFIX = $(patsubst %/,%,$(call prefix,$(PROJECT_DIR)))

BUILD_DIR = $(PREFIX)/Build

# We use this variable in the after-all script to note we detected a framework 
# or a library in a module and we have to export the related headers.
#EXPORTED = "NO"

# The code run by before-all creates a temporary header directory matching the
# project name. This allows to include headers within a library/framework by
# by using a statement like #import <PROJECT_NAME/header.h>. Such system-wide
# import is mandatory in installed headers of a library/framework.

before-all::
	$(ECHO_NOTHING) \
	echo ""; \
	echo "Build Project: $(PROJECT_NAME)"; \
	echo ""; \
	echo "$(FRAMEWORK_NAME) $(LIBRARY_NAME) $(PROJECT_DIR) $(PROJECT_NAME)"; \
	if [ ! -L $(PROJECT_DIR)/$(PROJECT_NAME) ]; then \
	  if [ -d $(PROJECT_DIR)/Headers ]; then \
	    $(LN_S) $(PROJECT_DIR)/Headers $(PROJECT_DIR)/$(PROJECT_NAME); \
	    echo "$(PROJECT_DIR) $(BUILD_DIR) $(PROJECT_NAME)"; \
	  elif [ -n "$(LIBRARY_NAME)" -o -n "$(FRAMEWORK_NAME)" ]; then \
	    $(LN_S) $(PROJECT_DIR) $(PROJECT_DIR)/$(PROJECT_NAME); \
	    echo "$(PROJECT_DIR) $(BUILD_DIR) $(PROJECT_NAME)"; \
	  fi; \
	fi; \
	$(END_ECHO)

# For debug, insert the next line close to the beginning of after-all.
#echo "etoile.make: PROJECT_DIR $(PROJECT_DIR) PROJECT_NAME $(PROJECT_NAME) BUILD_DIR $(BUILD_DIR)"; \
# For debug, insert the next line close to the end of after-all.
#echo "$(PROJECT_DIR) $(BUILD_DIR) $(PROJECT_NAME)"; \
#
# NOTE: Don't put these statements commented out directly in the code because
# it could make the build fails on some platforms as explained in bug report 
# #8484

# For framework, we create a symbolic link inside Build for the framework 
# itself inside but also a symbolic link libFrameworkName.so pointing on 
# frameworkName.framework/Versions/Current/libFrameworkName.so
# Not sure why it's needed, why gnustep-make isn't able to discover the library
# file by itself. Well... For now it avoids applications to pass any custom 
# flags to link frameworks inside Build directory 

after-all::
	$(ECHO_NOTHING) \
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
	fi; \
	if [ ! -d $(BUILD_DIR) ]; then \
	mkdir $(BUILD_DIR); \
	fi; \
	if [ -d  $(PROJECT_DIR)/$(PROJECT_NAME).framework ]; then \
	exported="yes"; \
	if [ ! -L $(BUILD_DIR)/$(PROJECT_NAME).framework ]; then \
	$(LN_S) $(PROJECT_DIR)/$(PROJECT_NAME).framework $(BUILD_DIR)/$(PROJECT_NAME).framework; \
	fi; \
	if [ ! -L $(BUILD_DIR)/lib$(PROJECT_NAME)$(SHARED_LIBEXT) ]; then \
	$(LN_S) $(PROJECT_DIR)/$(PROJECT_NAME).framework/Versions/Current/lib$(PROJECT_NAME)$(SHARED_LIBEXT) $(BUILD_DIR)/lib$(PROJECT_NAME)$(SHARED_LIBEXT); \
	fi; \
	fi; \
	if [ -f $(PROJECT_DIR)/obj/lib$(PROJECT_NAME)$(SHARED_LIBEXT) ]; then \
	exported="yes"; \
	if [ ! -L $(BUILD_DIR)/lib$(PROJECT_NAME)$(SHARED_LIBEXT) ]; then \
	$(LN_S) $(PROJECT_DIR)/obj/lib$(PROJECT_NAME)$(SHARED_LIBEXT) $(BUILD_DIR)/lib$(PROJECT_NAME)$(SHARED_LIBEXT) ; \
	fi; \
	fi; \
	if [ -f $(PROJECT_DIR)/Source/obj/lib$(PROJECT_NAME)$(SHARED_LIBEXT) ]; then \
	exported="yes"; \
	if [ ! -L $(BUILD_DIR)/lib$(PROJECT_NAME)$(SHARED_LIBEXT) ]; then \
	$(LN_S) $(PROJECT_DIR)/Source/obj/lib$(PROJECT_NAME)$(SHARED_LIBEXT) $(BUILD_DIR)/lib$(PROJECT_NAME)$(SHARED_LIBEXT) ; \
	fi; \
	fi; \
	if [ "$${exported}" = "yes" ]; then \
	if [ -d $(PROJECT_DIR)/Headers -a ! -L $(BUILD_DIR)/$(PROJECT_NAME) ]; then \
	$(LN_S) $(PROJECT_DIR)/Headers $(BUILD_DIR)/$(PROJECT_NAME); \
	elif [ ! -L $(BUILD_DIR)/$(PROJECT_NAME) ]; then \
	$(LN_S) $(PROJECT_DIR) $(BUILD_DIR)/$(PROJECT_NAME); \
	fi; \
	fi; \
	$(END_ECHO)

# Example with PROJECT_DIR variable only (based on PreferencesKitExample old 
# GNUmakefile.postamble):
#
# 	$(ECHO_NOTHING) \
# 	echo "Build Project: $(PROJECT_DIR)"; \
# 	echo ""; \
# 	rm -f $(PROJECT_DIR)/PreferencesKit; \
# 	$(LN_S) $(PROJECT_DIR)/../../../Frameworks/PreferencesKit/Headers $(PROJECT_DIR)/PreferencesKit; \
# 	echo " Imported PreferencesKit dependency"; \
# 	echo ""; \
# 	$(END_ECHO)

after-clean::
	$(ECHO_NOTHING) \
	echo ""; \
	if [ -z $(PROJECT_DIR) ]; then \
	echo "Dependency clean failed: PROJECT_DIR is not set"; \
	echo ""; \
	exit; \
	fi; \
	if [ -z $(PREFIX) ]; then \
	echo "Dependency clean failed: PREFIX is not set"; \
	echo ""; \
	exit; \
	fi; \
	if [ -z $(PROJECT_NAME) ]; then \
	echo "Dependency clean failed: PROJECT_NAME is not set"; \
	echo ""; \
	exit; \
	fi; \
	if [ -L $(BUILD_DIR)/$(PROJECT_NAME) ]; then \
	rm -f $(BUILD_DIR)/$(PROJECT_NAME); \
	removed="yes"; \
	fi; \
	if [ -L $(BUILD_DIR)/lib$(PROJECT_NAME)$(SHARED_LIBEXT) ]; then \
	rm -f $(BUILD_DIR)/lib$(PROJECT_NAME)$(SHARED_LIBEXT); \
	removed="yes"; \
	fi; \
	if [ -L $(BUILD_DIR)/$(PROJECT_NAME).framework ]; then \
	rm -f $(BUILD_DIR)/$(PROJECT_NAME).framework; \
	removed="yes"; \
	fi; \
	if [ "$${removed}" = "yes" ]; then \
	echo " Removed $(PROJECT_NAME) dependency export"; \
	echo ""; \
	fi; \
	$(END_ECHO)

after-distclean::
	$(ECHO_NOTHING) \
	echo ""; \
	if [ -z $(PROJECT_DIR) ]; then \
	echo "Dependency clean failed: PROJECT_DIR is not set"; \
	echo ""; \
	exit; \
	fi; \
	if [ -z $(PREFIX) ]; then \
	echo "Dependency clean failed: PREFIX is not set"; \
	echo ""; \
	exit; \
	fi; \
	if [ -z $(PROJECT_NAME) ]; then \
	echo "Dependency clean failed: PROJECT_NAME is not set"; \
	echo ""; \
	exit; \
	fi; \
	if [ -L $(BUILD_DIR)/$(PROJECT_NAME) ]; then \
	rm -f $(BUILD_DIR)/$(PROJECT_NAME); \
	removed="yes"; \
	fi; \
	if [ -L $(BUILD_DIR)/lib$(PROJECT_NAME)$(SHARED_LIBEXT) ]; then \
	rm -f $(BUILD_DIR)/lib$(PROJECT_NAME)$(SHARED_LIBEXT); \
	removed="yes"; \
	fi; \
	if [ -L $(BUILD_DIR)/$(PROJECT_NAME).framework ]; then \
	rm -f $(BUILD_DIR)/$(PROJECT_NAME).framework; \
	removed="yes"; \
	fi; \
	if [ "$${removed}" = "yes" ]; then \
	echo " Removed $(PROJECT_NAME) dependency export"; \
	echo ""; \
	fi; \
	$(END_ECHO)


### Default Variable Values For Conveniency ###

# You can overidde any variable values defined by below by resetting the value
# in the GNUmakefile.preamble of your module. For example:
# unexport ADDITIONAL_INCLUDE_DIRS = 
# If you don't put 'unexport' in front of the variable name, the variable will
# be reset but still exported to submake instances (this is never the case with
# gnustep-make variables, that's why you must include a GNUmakefile.preamble in
# any subdirectories of your module usually).

# If we have dependency, once it's imported we need to include its headers
# located PROJECT_DIR/PROJECT_NAME. This means we have to look in 
# PROJECT_DIR since we usually use include directive like 
# #import <PROJECT_NAME/header.h>
#
# By default we also look for headers in PROJECT_DIR and PROJECT_DIR/Headers, 
# this conveniency avoids to take care of such flags over and over.

export ADDITIONAL_INCLUDE_DIRS += -I$(BUILD_DIR) -I$(PROJECT_DIR) -I$(PROJECT_DIR)/Headers

# If we have dependency, we need to link its resulting object file. Well, we
# have to look for a library or a framework most of time.
#
# NOTE: We cannot use $(GNUSTEP_SHARED_OBJ) instead of shared_obj because the 
# former variable is relative to the project and could be modified by the 
# developer. For example, it's commonly equals to ./shared_obj

export ADDITIONAL_LIB_DIRS += -L$(BUILD_DIR)

# We disable warnings about #import being deprecated. They occur with old GCC
# version (before 4.0 iirc).
export ADDITIONAL_OBJCFLAGS += -Wno-import -Werror -Wno-unused

# For test bundles, we must link UnitKit
ifeq ($(test), yes)
  ifeq ($(FOUNDATION_LIB), apple)
    export ADDITIONAL_OBJC_LIBS += -framework UnitKit
  else
    export ADDITIONAL_OBJC_LIBS += -lUnitKit
  endif
endif
