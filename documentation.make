#
# Etoile Documentation Makefile
#
# Inlude it right after etoile.make, like that:
# -include path/to/repository/root/etoile.make
# -include path/to/repository/root/documentation.make
#
# Any doc-related overriden variables should be put before these include 
# statements.
#
# Usually this should be enough to build the doc. If not, you can override with 
# documentation-related variables in the project GNUmakefile:
# $(DOC_NAME)_DOC_FILES = .h and .m paths relative to $(PROJECT_DIR)
# $(DOC_NAME)_EXCLUDED_DOC_FILES = .h and .m paths relative to $(PROJECT_DIR)
# $(DOC_NAME)_AGSDOC_EXTRA_FLAGS = autogsdoc options
# where $(DOC_NAME)is your project name suffixed with 'Doc'.

# For example, to get a more verbose output:
# EtoileFoundationDoc_AGSDOC_EXTRA_FLAGS = -Verbose YES
#
# $(DOC_NAME) is not defined before 'include documentation.make', that's why 
# 'ProjectNameDoc' (in the example EtoileFoundationDoc) must be used. If you 
# prefer, you can redefine DOC_NAME.
#
# Few additional variables are provided:
# $(DOC_NAME)_DOCUMENTATION_DIR = ./Documentation
# $(DOC_NAME)_HEADER_DIRS = '.' and './Headers'
# $(DOC_NAME)_SOURCE_DIRS = '.' and './Source'
# If you override a variable above such as $(DOC_NAME)_SOURCE_DIRS and still 
# want to use the project directory as a search path, you must redeclare it:
# $(DOC_NAME)_SOURCE_DIRS = . SourceCodeDir1 SourceCodeDir2
#
# The .h and .m files found in the directories provided with 
# $(DOC_NAME)_HEADER_DIRS and $(DOC_NAME)_SOURCE_DIRS are appended to 
# $(DOC_NAME)_DOC_FILES.
#
# You can use $(DOC_NAME)_DOC_FILES to declare explicitly every .h and .m files 
# to be processed, but you must then prevent the header and source directories 
# to be visited by documentation.make as done below:
# $(DOC_NAME)_HEADER_DIRS=
# $(DOC_NAME)_SOURCE_DIRS=
#
# Files named TestXXX.m or TestXXX.c are not included in $(DOC_NAME)_DOC_FILES
#
# HTML templates can be customized to use other template paths:
# $(DOC_NAME)_MAIN_TEMPLATE_FILE = Developer/DocGenerator/Templates/etoile-documentation-template.html
# $(DOC_NAME)_MENU_TEMPLATE_FILE = Developer/Services/DocGenerator/Templates/menu.html
#
# Presentation, Installation and Revision History sections in the default menu 
# represent respectively the Markdown files below if not overriden:
# $(DOC_NAME)_README_FILE = ./README
# $(DOC_NAME)_INSTALL_FILE = ./INSTALL
# $(DOC_NAME)_NEWS_FILE = ./NEWS
#
# This makefile creates a Documentation directory inside your project unless 
# you override $(DOC_NAME)_DOCUMENTATION_DIR.
# The html ouput is also copied to Developer/Documentation/yourProjectName.
#
# To get some debug infos, append 'debug-doc=yes' to 'make doc' or 
# 'make documentation=yes'. Use 'make debug-doc' to print out documentation 
# variables and return immediately (no documentation generation).
#

DOC_NAME ?= $(PROJECT_NAME)Doc

$(DOC_NAME)_DOCUMENTATION_DIR ?= $(PROJECT_DIR)/Documentation
$(DOC_NAME)_HEADER_DIRS ?= $(PROJECT_DIR)/Headers $(PROJECT_DIR)
$(DOC_NAME)_SOURCE_DIRS ?= $(PROJECT_DIR)/Source $(PROJECT_DIR)
# OTHER_SOURCE_DIR is deprecated 
$(DOC_NAME)_OTHER_SOURCE_DIR =

# Expand relative paths in variables which allows it
ifdef $(DOC_NAME)_DOC_FILES
  $(DOC_NAME)_DOC_FILES := $(foreach file, $($(DOC_NAME)_DOC_FILES), $(PROJECT_DIR)/$(wildcard $(file)))
endif
$(DOC_NAME)_EXCLUDED_DOC_FILES := $(foreach file, $($(DOC_NAME)_EXCLUDED_DOC_FILES), $(PROJECT_DIR)/$(wildcard $(file)))

# Collect .h and .m paths in header and source directories
$(DOC_NAME)_DOC_FILES += $(foreach headerdir, $($(DOC_NAME)_HEADER_DIRS), $(wildcard $(headerdir)/*.h))
$(DOC_NAME)_DOC_FILES += $(foreach sourcedir, $($(DOC_NAME)_SOURCE_DIRS), $(wildcard $(sourcedir)/[^T]?[^e]?[^s]?[^t]?*.m))
$(DOC_NAME)_DOC_FILES += $(foreach sourcedir, $($(DOC_NAME)_SOURCE_DIRS), $(wildcard $(sourcedir)/[^T]?[^e]?[^s]?[^t]?*.c))

# Remove .h and .m paths for which no doc should be generated
$(DOC_NAME)_DOC_FILES := $(foreach file, $($(DOC_NAME)_DOC_FILES), \
  $(if $(findstring $(file), $($(DOC_NAME)_EXCLUDED_DOC_FILES)),, $(file)))

# autogsdoc variables (do not use or override)
$(DOC_NAME)_AGSDOC_FILES := $($(DOC_NAME)_DOC_FILES)

# etdocgen variables
$(DOC_NAME)_MAIN_TEMPLATE_FILE ?= $(PREFIX)/Developer/Services/DocGenerator/Templates/etoile-documentation-template.html
$(DOC_NAME)_MENU_TEMPLATE_FILE ?= $(PREFIX)/Developer/Services/DocGenerator/Templates/menu.html
$(DOC_NAME)_EXTERNAL_INDEX_UNIT_FILES += $(PREFIX)/Developer/Services/DocGenerator/TestFiles/class-mapping.plist
$(DOC_NAME)_GSDOC_FILES += $(foreach sourcedir, $($(DOC_NAME)_DOCUMENTATION_DIR)/GSDoc, $(wildcard $(sourcedir)/*.gsdoc))
$(DOC_NAME)_GSDOC_FILES += $(foreach sourcedir, $($(DOC_NAME)_DOCUMENTATION_DIR)/GSDoc, $(wildcard $(sourcedir)/*.gsdoc))
$(DOC_NAME)_README_FILE ?= $(wildcard $(PROJECT_DIR)/README)
$(DOC_NAME)_INSTALL_FILE ?= $(wildcard $(PROJECT_DIR)/INSTALL)
$(DOC_NAME)_NEWS_FILE ?= $(wildcard $(PROJECT_DIR)/NEWS) 

# Some shortcut variables
DEV_DOC_DIR = $(PREFIX)/Developer/Documentation
PROJECT_DOC_DIR = $($(DOC_NAME)_DOCUMENTATION_DIR)

# We pass -Project otherwise the title is DOC_NAME with the Doc suffix
$(DOC_NAME)_AGSDOC_FLAGS = \
	-Project $(PROJECT_NAME) \
	-MakeFrames YES \
	-DocumentationDirectory $($(DOC_NAME)_DOCUMENTATION_DIR)/GSDoc \
	-GenerateParagraphMarkup YES \
	-Warn NO

.PHONY: doc before-doc gsdocgen etdocgen after-doc debug-doc

# The user-visible target used to build the documentation
doc: before-doc gsdocgen etdocgen after-doc

# The main target that invokes autogsdoc to output .gsdoc and .html files
gsdocgen:
	autogsdoc $($(DOC_NAME)_AGSDOC_FLAGS) $($(DOC_NAME)_AGSDOC_EXTRA_FLAGS) -Files $($(DOC_NAME)_DOCUMENTATION_DIR)/doc-make-dependencies

FLAG_OTHER_SOURCE_DIR = $(if $(strip $($(DOC_NAME)_OTHER_SOURCE_DIR)),-r $($(DOC_NAME)_OTHER_SOURCE_DIR),)

etdocgen:
	etdocgen -n $(PROJECT_NAME) -c $(PROJECT_DOC_DIR)/GSDoc $(FLAG_OTHER_SOURCE_DIR) -t $($(DOC_NAME)_MAIN_TEMPLATE_FILE) -m $($(DOC_NAME)_MENU_TEMPLATE_FILE) -e $($(DOC_NAME)_EXTERNAL_INDEX_UNIT_FILES) -o $(PROJECT_DOC_DIR) $($(DOC_NAME)_README_FILE) $($(DOC_NAME)_INSTALL_FILE) $($(DOC_NAME)_NEWS_FILE)

# A debugging target useful to print out the documentation.make variables without 
# any tool invocation
debug-doc:
	export debug-doc=yes 

# Build the plist array saved as doc-make-dependencies in before-doc and 
# passed to autogsdoc with -Files in internal-doc
comma := ,
blank := 
space := $(blank) $(blank)
$(DOC_NAME)_AGSDOC_FILES := $(strip $($(DOC_NAME)_AGSDOC_FILES))
AGSDOC_FILE_ARRAY := $(subst $(space),$(comma)$(space),($($(DOC_NAME)_AGSDOC_FILES)))

ifeq ($(debug-doc), yes)
  $(warning $(DOC_NAME)_HEADER_DIRS=$($(DOC_NAME)_HEADER_DIRS))
  $(warning $(DOC_NAME)_SOURCE_DIRS=$($(DOC_NAME)_SOURCE_DIRS))
  $(warning $(DOC_NAME)_EXCLUDED_DOC_FILES=$($(DOC_NAME)_EXCLUDED_DOC_FILES))
  $(warning $(DOC_NAME)_DOC_FILES=$($(DOC_NAME)_DOC_FILES))
  $(warning $(DOC_NAME)_AGSDOC_FLAGS=$($(DOC_NAME)_AGSDOC_FLAGS))
  $(warning AGSDOC_FILE_ARRAY = $(AGSDOC_FILE_ARRAY))
  $(warning DEV_DOC_DIR = $(DEV_DOC_DIR))
  $(warning PROJECT_DOC_DIR = $(PROJECT_DOC_DIR))
endif

# Create the Documentation directory and a file that contains the .h and .m file list
before-doc:
	if [ ! -d $(PROJECT_DOC_DIR) ];  then \
		mkdir $(PROJECT_DOC_DIR); \
	fi; \
	if [ ! -d $(PROJECT_DOC_DIR)/GSDoc ];  then \
		mkdir $(PROJECT_DOC_DIR)/GSDoc; \
	fi; \
	if [ ! -e images ];  then \
		ln -s $(PREFIX)/Developer/Services/DocGenerator/Templates/images images; \
	fi; \
	if [ ! -e $_includes ];  then \
		ln -s $(PREFIX)/Developer/Services/DocGenerator/Templates/_includes _includes; \
	fi; \
	echo "$(AGSDOC_FILE_ARRAY)" > $(PROJECT_DOC_DIR)/doc-make-dependencies

# Export the generated doc to Developer/Documentation and recreate the index.html there
after-doc:
	$(ECHO_NOTHING) \
	if [ ! -d $(DEV_DOC_DIR) ]; then \
		mkdir $(DEV_DOC_DIR); \
	fi; \
	if [ ! -d $(DEV_DOC_DIR)/$(PROJECT_NAME) ]; then \
		mkdir $(DEV_DOC_DIR)/$(PROJECT_NAME); \
	fi; \
	for file in $(PROJECT_DOC_DIR)/*.html; do \
		if [ -f $$file ]; then \
			cp $$file $(DEV_DOC_DIR)/$(PROJECT_NAME); \
		fi; \
	done; \
	cd $(DEV_DOC_DIR) && $(DEV_DOC_DIR)/create-project-doc-index.sh > $(DEV_DOC_DIR)/index.html; \
	$(END_ECHO)

# The user-visible target to remove generated content
# autogsdoc -Clean YES doesn't work well, it removes the html files if I pass *
# but that's it, so let's do it with rm...
# We also remove stuff previously copied to Developer/Documentation 
clean-doc:
	$(ECHO_NOTHING) \
	rm _includes \
	rm images \
	rm -f $(PROJECT_DOC_DIR)/doc-make-dependencies \
	rm -f $(PROJECT_DOC_DIR)/GSDoc/*.igsdoc \
	rm -f $(PROJECT_DOC_DIR)/GSDoc/*.gsdoc \
	rm -f $(PROJECT_DOC_DIR)/GSDoc/*.html \
	rm -f $(PROJECT_DOC_DIR)/GSDoc/*.plist \
	rm -f $(PROJECT_DOC_DIR)/*.igsdoc \
	rm -f $(PROJECT_DOC_DIR)/*.gsdoc \
	rm -f $(PROJECT_DOC_DIR)/*.html \
	rm -f $(PROJECT_DOC_DIR)/*.png \
	rm -f $(DEV_DOC_DIR)/$(PROJECT_NAME)/*.html \
	$(END_ECHO)

# GNUstep Make Integration

ifeq ($(documentation), yes)
after-all:: doc
endif

after-distclean:: clean-doc

