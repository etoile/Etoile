#
# Etoile Makefile Extensions (dependency support, test support, etc.)
#


### Debug, profile adjustments for bundles ###

ifeq ($(debug), yes)
	extension = debug
else
	extension = app
endif


### Internal dependency handling ###

#
# To declare one or several dependencies, use the variable DEPENDENCIES. For
# example 
# DEPENDENCIES = PreferencesKit UnitKit 
# means your project depends on PreferencesKit and UnitKit, by the way needs to
# include and link them. 
# Take note etoile.make won't alter the build order of modules, then you have 
# to specify it properly in the root GNUmakefile in order to have your project 
# building after PreferencesKit and UnitKit.
#

EtoileExtensionsKit = Frameworks/EtoileExtensionsKit
LuceneKit = Frameworks/LuceneKit
OgreKit = Frameworks/OgreKit
PreferencesKit = Frameworks/PreferencesKit
RSSKit = Frameworks/RSSKit
UnitKit = Frameworks/UnitKit
XWindowServerKit = Frameworks/XWindowServerKit

# FIXME: For now we support only one dependency specified through DEPENDENCIES,
# that's why we extract the only dependency stored in it and put it into 
# DEPENDENCY variable currently used our code.

DEPENDENCY = $(DEPENDENCIES)

# We treat the value of the variable DEPENDENCY as a variable. Here is an 
# example of what happens:
# PreferencesKit =  Frameworks/PreferencesKit
# DEPENDENCY = PreferencesKit
# DEPENDENCY_PATH = Frameworks/PreferencesKit
# because $($(DEPENDENCY)) == $(PreferencesKit) == Frameworks/PreferencesKit

DEPENDENCY_PATH = $($(DEPENDENCY))

# CURDIR is the path where make is run, with gnustep-make the value changes in
# subdirectories since each 'submake' is a 'normal' make, sandboxed and not 
# run recursively from the initial directory.
#
# PROJECT_DIR is the path where make is invoked, the first directory where 
# make is run, this variable allows to keep a reference to the initial 
# directory taking in account the previous comment about CURDIR.
#
# PWD or ./ is the path where the current makefile is located (for 
# etoile.make, this is always Etoile/)

export PROJECT_DIR ?= $(CURDIR)

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

before-all::
	$(ECHO_NOTHING) \
	echo ""; \
	echo "Build Project: $(PROJECT_DIR)"; \
	echo ""; \
	if [ -z $(DEPENDENCIES) ]; then \
	exit; \
	fi; \
	if [ -z $(PROJECT_DIR) ]; then \
	echo "Dependency import failed: PROJECT_DIR is not set"; \
	echo ""; \
	exit; \
	fi; \
	if [ -z $(PREFIX) ]; then \
	echo "Dependency import failed: PREFIX is not set"; \
	echo ""; \
	exit; \
	fi; \
	if [ -z $(DEPENDENCY) ]; then \
	echo "Dependency import failed: DEPENDENCY is not set"; \
	echo ""; \
	exit; \
	fi; \
	if [ -z $(DEPENDENCY_PATH) ]; then \
	echo "Dependency import failed: DEPENDENCY_PATH is not set"; \
	echo ""; \
	exit; \
	fi; \
	rm -f $(PROJECT_DIR)/$(DEPENDENCY); \
	if [ -d $(PREFIX)/$(DEPENDENCY_PATH)/Headers ]; then \
	$(LN_S) $(PREFIX)/$(DEPENDENCY_PATH)/Headers $(PROJECT_DIR)/$(DEPENDENCY); \
	else \
	$(LN_S) $(PREFIX)/$(DEPENDENCY_PATH) $(PROJECT_DIR)/$(DEPENDENCY); \
	fi; \
	echo " Imported $(DEPENDENCY) dependency"; \
	echo ""; \
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
	if [ -z $(DEPENDENCIES) ]; then \
	exit; \
	fi; \
	if [ -z $(PROJECT_DIR) ]; then \
	echo "Dependency import failed: PROJECT_DIR is not set"; \
	echo ""; \
	exit; \
	fi; \
	if [ -z $(DEPENDENCY) ]; then \
	echo "Dependency import failed: DEPENDENCY is not set"; \
	echo ""; \
	exit; \
	fi; \
	rm -f $(PROJECT_DIR)/$(DEPENDENCY); \
	echo " Removed $(DEPENDENCY) dependency import"; \
	echo ""; \
	$(END_ECHO)

after-distclean::
	$(ECHO_NOTHING) \
	echo ""; \
	if [ -z $(DEPENDENCIES) ]; then \
	exit; \
	fi; \
	if [ -z $(PROJECT_DIR) ]; then \
	echo "Dependency import failed: PROJECT_DIR is not set"; \
	echo ""; \
	exit; \
	fi; \
	if [ -z $(DEPENDENCY) ]; then \
	echo "Dependency import failed: DEPENDENCY is not set"; \
	echo ""; \
	exit; \
	fi; \
	rm -f $(PROJECT_DIR)/$(DEPENDENCY); \
	echo " Removed $(DEPENDENCY) dependency import"; \
	echo ""; \
	$(END_ECHO)

# If we have dependency, once it's imported we need to include its headers
# located PROJECT_DIR/DEPENDENCY. This means we have to look in 
# PROJECT_DIR since we usually use include directive like 
# #import <DEPENDENCY_NAME/header.h>

ADDITIONAL_INCLUDE_DIRS += -I$(PROJECT_DIR)

# If we have dependency, we need to link its resulting object file. Well, we
# have to look for a library or a framework most of time.
#
# NOTE: We cannot use $(GNUSTEP_SHARED_OBJ) instead of shared_obj because the 
# former variable is relative to the project and could be modified by the 
# developer. For example, it's commonly equals to ./shared_obj

ADDITIONAL_LIB_DIRS += -L$(PREFIX)/$(DEPENDENCY_PATH)/shared_obj  \
    -L$(PREFIX)/$(DEPENDENCY_PATH)/$(DEPENDENCY).framework/Versions/Current

