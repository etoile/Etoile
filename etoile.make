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

PROJECT_NAME = $(notdir $(PROJECT_DIR))

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

before-all::
	$(ECHO_NOTHING) \
	echo ""; \
	echo "Build Project: $(PROJECT_NAME)"; \
	echo ""; \
	$(END_ECHO)

after-all::
	$(ECHO_NOTHING) \
	echo "etoile.make: PROJECT_DIR $(PROJECT_DIR) PROJECT_NAME $(PROJECT_NAME) BUILD_DIR $(BUILD_DIR)"; \
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
	exported="YES"; \
	if [ ! -L $(BUILD_DIR)/$(PROJECT_NAME).framework ]; then \
	$(LN_S) $(PROJECT_DIR)/obj/$(PROJECT_NAME).framework $(BUILD_DIR)/$(PROJECT_NAME).framework; \
	fi; \
	fi; \
	if [ -f $(PROJECT_DIR)/obj/lib$(PROJECT_NAME).so ]; then \
	echo "exported 1"; \
	exported="yes"; \
	if [ ! -L $(BUILD_DIR)/lib$(PROJECT_NAME).so ]; then \
	$(LN_S) $(PROJECT_DIR)/obj/lib$(PROJECT_NAME).so $(BUILD_DIR)/lib$(PROJECT_NAME).so; \
	fi; \
	fi; \
	echo "blabla $${exported}"; \
	if [ "$${exported}" = "yes" ]; then \
	echo "exported 2"; \
	if [ -d $(PROJECT_DIR)/Headers -a ! -L $(BUILD_DIR)/$(PROJECT_NAME) ]; then \
	$(LN_S) $(PROJECT_DIR)/Headers $(BUILD_DIR)/$(PROJECT_NAME); \
	elif [ ! -L $(BUILD_DIR)/$(PROJECT_NAME) ]; then \
	echo "$(PROJECT_DIR) $(BUILD_DIR) $(PROJECT_NAME)"; \
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
	if [ -L $(BUILD_DIR)/$(PROJECT_NAME).so ]; then \
	rm -f $(BUILD_DIR)/lib$(PROJECT_NAME).so; \
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
	if [ -L $(BUILD_DIR)/$(PROJECT_NAME).so ]; then \
	rm -f $(BUILD_DIR)/lib$(PROJECT_NAME).so; \
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

# If we have dependency, once it's imported we need to include its headers
# located PROJECT_DIR/PROJECT_NAME. This means we have to look in 
# PROJECT_DIR since we usually use include directive like 
# #import <PROJECT_NAME_NAME/header.h>

ADDITIONAL_INCLUDE_DIRS += -I$(BUILD_DIR)

# If we have dependency, we need to link its resulting object file. Well, we
# have to look for a library or a framework most of time.
#
# NOTE: We cannot use $(GNUSTEP_SHARED_OBJ) instead of shared_obj because the 
# former variable is relative to the project and could be modified by the 
# developer. For example, it's commonly equals to ./shared_obj

ADDITIONAL_LIB_DIRS += -L$(BUILD_DIR)

