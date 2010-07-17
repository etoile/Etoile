#
# Etoile Documentation Makefile
#
# Inlude it right after etoile.make, like that:
# -include path/to/repository/root/etoile.make
# -include path/to/repository/root/documentation.make
#
# Usually this should be enough to build the doc. If not, you can override with 
# = or += AGSDOC_XXX variables in the project GNUmakefile.
#
# Few additional variables are provided:
# $(DOCUMENT_NAME)_DOCUMENTATION_DIR
# $(DOCUMENT_NAME)_HEADER_DIR
# $(DOCUMENT_NAME)_SOURCE_DIRS
# where $(DOCUMENT_NAME)is your project name suffixed with 'Doc'.
#
# This makefile creates a Documentation directory inside your project.
# The html ouput is also copied to Developer/Documentation/yourProjectName.
#

# NOTE: autogsdoc creates a private directory whose name is DOCUMENT_NAME. For 
# that reason we cannot do DOCUMENT_NAME = $(PROJECT_NAME) because etoile.make 
# already creates an identically named temporary directory where headers are 
# collected.
DOCUMENT_NAME = $(PROJECT_NAME)Doc

$(DOCUMENT_NAME)_DOCUMENTATION_DIR = $(PROJECT_DIR)/Documentation
# We reuse the temporary header directory built by etoile.make
$(DOCUMENT_NAME)_HEADER_DIR = $(PROJECT_DIR)/$(PROJECT_NAME)
# Extension to let us specify where source files can be found
$(DOCUMENT_NAME)_SOURCE_DIRS = $(PROJECT_DIR)/Source $(PROJECT_DIR)


$(DOCUMENT_NAME)_AGSDOC_FILES = $(wildcard $($(DOCUMENT_NAME)_HEADER_DIR)/*.h)
$(DOCUMENT_NAME)_AGSDOC_FILES += $(wildcard $(PROJECT_DIR)/Source/*.m)

#$(DOCUMENT_NAME)_AGSDOC_FILES += $(foreach sourcedir, $($(DOCUMENT_NAME)_SOURCE_DIRS), $(notdir $(wildcard $(sourcedir)/*.m)))

# We pass -Project otherwise the title is DOCUMENT_NAME with the Doc suffix
$(DOCUMENT_NAME)_AGSDOC_FLAGS = \
	-Project $(PROJECT_NAME) \
	-MakeFrames YES \
	-DocumentationDirectory $($(DOCUMENT_NAME)_DOCUMENTATION_DIR) \
	-GenerateParagraphMarkup YES \
	-Warn YES

#	-Verbose YES
#	-Clean YES
#	-IgnoreDependencies YES

doc: before-doc internal-doc

internal-doc:
	autogsdoc $($(DOCUMENT_NAME)_AGSDOC_FLAGS) -Files $($(DOCUMENT_NAME)_DOCUMENTATION_DIR)/doc-make-dependencies

DEV_DOC_DIR = $(PREFIX)/Developer/Documentation
PROJECT_DOC_DIR = $($(DOCUMENT_NAME)_DOCUMENTATION_DIR)
comma := ,
blank := 
space := $(blank) $(blank)
AGSDOC_FILE_ARRAY := $(subst $(space),$(comma)$(space),($($(DOCUMENT_NAME)_AGSDOC_FILES)))


ifeq ($(debug-doc), yes)
$(warning $(DOCUMENT_NAME)_AGSDOC_FLAGS=$($(DOCUMENT_NAME)_AGSDOC_FLAGS))
$(warning $(DOCUMENT_NAME)_AGSDOC_FILES=$($(DOCUMENT_NAME)_AGSDOC_FILES))
$(warning AGSDOC_FILE_ARRAY = $(AGSDOC_FILE_ARRAY))
$(warning DEV_DOC_DIR = $(DEV_DOC_DIR))
$(warning PROJECT_DOC_DIR = $(PROJECT_DOC_DIR))
endif

# We cannot give a Source directory to autogsdoc through gnustep-make, and 
# an explicit declaration $(DOCUMENT_NAME)_AGSDOC_FILES += ../COObject.m doesn't
# work either. autogsdoc only collects sources files in the current directory 
# and documentation directory (and header directory may be too). Let's work 
# around that with ln...
before-doc:
	if [ ! -d $(PROJECT_DOC_DIR) ];  then \
		mkdir $(PROJECT_DOC_DIR); \
	fi; \
	echo "$(AGSDOC_FILE_ARRAY)" > $(PROJECT_DOC_DIR)/doc-make-dependencies

after-doc:
	$(ECHO_NOTHING) \
	for mfile in $(PROJECT_DOC_DIR)/*.m; do \
		if [ -L $mfile ]; then \
			rm -f $mfile; \
		fi; \
	done; \
	if [ ! -d $(DEV_DOC_DIR) ]; then \
		mkdir $(DEV_DOC_DIR); \
	fi; \
	if [ ! -d $(DEV_DOC_DIR)/$(PROJECT_NAME) ]; then \
		mkdir $(DEV_DOC_DIR)/$(PROJECT_NAME); \
	fi; \
	for htmlfile in $(PROJECT_DOC_DIR)/*.html; do \
		if [ -f $htmlfile ]; then \
			cp -f $htmlfile $(DEV_DOC_DIR)/$(PROJECT_NAME); \
		fi; \
	done; \
	$(END_ECHO)


# autogsdoc -Clean YES doesn't work well, it removes the html files if I pass *
# but that's it, so let's do it with rm...
clean-doc:
	$(ECHO_NOTHING) \
	rm -f $(PROJECT_DOC_DIR)/doc-make-dependencies \
	rm -f $(PROJECT_DOC_DIR)/*.igsdoc \
	rm -f $(PROJECT_DOC_DIR)/*.gsdoc \
	rm -f $(PROJECT_DOC_DIR)/*.html \
	rm -f $(DEV_DOC_DIR)/$(PROJECT_NAME)/*.html \
	$(END_ECHO)

after-distclean:: clean-doc
