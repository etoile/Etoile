#
# Etoile Documentation Makefile
#
# Inlude it right after etoile.make, like that:
# -include path/to/repository/root/etoile.make
# -include path/to/repository/root/documentation.make
#
# Usually this should be enough to build the doc. If not, you can override with 
# = or += AGSDOC_XXX variables in the project GNUmakefile:
# $(DOCUMENT_NAME)_AGSDOC_FILES = .h and .m paths
# $(DOCUMENT_NAME)_AGSDOC_FLAGS = autogsdoc options
#
# For example, to get a more verbose output:
# # $(DOCUMENT_NAME)_AGSDOC_FLAGS += -Verbose YES
#
# Few additional variables are provided:
# $(DOCUMENT_NAME)_DOCUMENTATION_DIR = ./Documentation
# $(DOCUMENT_NAME)_HEADER_DIRS = '.' and './Headers'
# $(DOCUMENT_NAME)_SOURCE_DIRS = '.' and './Source'
# where $(DOCUMENT_NAME)is your project name suffixed with 'Doc'.
#
# The .h and .m files found in the directories provided with 
# $(DOCUMENT_NAME)_HEADER_DIRS and $(DOCUMENT_NAME)_SOURCE_DIRS are appended to 
# $(DOCUMENT_NAME)_AGSDOC_FILES
#
# This makefile creates a Documentation directory inside your project unless 
# you override $(DOCUMENT_NAME)_DOCUMENTATION_DIR.
# The html ouput is also copied to Developer/Documentation/yourProjectName.
#
# To get some debug infos, pass 'debug-doc=yes' to 'make'
#

DOCUMENT_NAME = $(PROJECT_NAME)Doc

$(DOCUMENT_NAME)_DOCUMENTATION_DIR = $(PROJECT_DIR)/Documentation
$(DOCUMENT_NAME)_HEADER_DIRS += $(PROJECT_DIR)/Headers $(PROJECT_DIR)
$(DOCUMENT_NAME)_SOURCE_DIRS += $(PROJECT_DIR)/Source $(PROJECT_DIR)

$(DOCUMENT_NAME)_AGSDOC_FILES += $(foreach headerdir, $($(DOCUMENT_NAME)_HEADER_DIRS), $(wildcard $(headerdir)/*.h))
$(DOCUMENT_NAME)_AGSDOC_FILES += $(foreach sourcedir, $($(DOCUMENT_NAME)_SOURCE_DIRS), $(wildcard $(sourcedir)/*.m))


# We pass -Project otherwise the title is DOCUMENT_NAME with the Doc suffix
$(DOCUMENT_NAME)_AGSDOC_FLAGS = \
	-Project $(PROJECT_NAME) \
	-MakeFrames YES \
	-DocumentationDirectory $($(DOCUMENT_NAME)_DOCUMENTATION_DIR) \
	-GenerateParagraphMarkup YES \
	-Warn YES

# The user-visible target used to build the documentation
doc: before-doc internal-doc after-doc

# The main target that invokes autogsdoc to output .gsdoc and .html files
internal-doc:
	autogsdoc $($(DOCUMENT_NAME)_AGSDOC_FLAGS) -Files $($(DOCUMENT_NAME)_DOCUMENTATION_DIR)/doc-make-dependencies

# Some shortcut variables
DEV_DOC_DIR = $(PREFIX)/Developer/Documentation
PROJECT_DOC_DIR = $($(DOCUMENT_NAME)_DOCUMENTATION_DIR)

# Build the plist array saved as doc-make-dependencies in before-doc and 
# passed to autogsdoc with -Files in internal-doc
comma := ,
blank := 
space := $(blank) $(blank)
$(DOCUMENT_NAME)_AGSDOC_FILES := $(strip $($(DOCUMENT_NAME)_AGSDOC_FILES))
AGSDOC_FILE_ARRAY := $(subst $(space),$(comma)$(space),($($(DOCUMENT_NAME)_AGSDOC_FILES)))

# Output debug infos if requested
ifeq ($(debug-doc), yes)
$(warning $(DOCUMENT_NAME)_HEADER_DIRS=$($(DOCUMENT_NAME)_HEADER_DIRS))
$(warning $(DOCUMENT_NAME)_AGSDOC_FLAGS=$($(DOCUMENT_NAME)_AGSDOC_FLAGS))
$(warning $(DOCUMENT_NAME)_AGSDOC_FILES=$($(DOCUMENT_NAME)_AGSDOC_FILES))
$(warning AGSDOC_FILE_ARRAY = $(AGSDOC_FILE_ARRAY))
$(warning DEV_DOC_DIR = $(DEV_DOC_DIR))
$(warning PROJECT_DOC_DIR = $(PROJECT_DOC_DIR))
endif

# Create the Documentation directory and a file that contains the .h and .m file list
before-doc:
	if [ ! -d $(PROJECT_DOC_DIR) ];  then \
		mkdir $(PROJECT_DOC_DIR); \
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
	rm -f $(PROJECT_DOC_DIR)/doc-make-dependencies \
	rm -f $(PROJECT_DOC_DIR)/*.igsdoc \
	rm -f $(PROJECT_DOC_DIR)/*.gsdoc \
	rm -f $(PROJECT_DOC_DIR)/*.html \
	rm -f $(DEV_DOC_DIR)/$(PROJECT_NAME)/*.html \
	$(END_ECHO)

# GNUstep Make Integration

ifeq ($(documentation), yes)
after-all:: doc
endif

after-distclean:: clean-doc

