# Makefile for statically compiling pragmatic smalltalk modules. Needs to be
# included after the project specific makefile statements but before the include
# directive that includes the project type specific makefile from gnustep-make. 
#
# Created: April 2012
#
# Written by Niels Grewe <niels.grewe@halbordnung.de>


# Place smalltalk files into the GNUSTEP_OBJ_INSTANCE_DIR, eventhough
# gnustep-make hides the variable from us.
ifeq ($(strip $(GNUSTEP_OBJ_INSTANCE_DIR)),)
GNUSTEP_OBJ_INSTANCE_DIR=$(GNUSTEP_BUILD_DIR)/$(GNUSTEP_INSTANCE).obj
endif
SMALLTALK_BITCODES = $(patsubst %.st,%.st.bc,$($(GNUSTEP_INSTANCE)_SMALLTALK_FILES))
SMALLTALK_BITCODE_FILES = $(addprefix $(GNUSTEP_OBJ_INSTANCE_DIR)/,$(SMALLTALK_BITCODES))

# The bitcode location for MsgSendSmallInt can be overridden, e.g. if
# LanguageKit was installed into a different installation domain.
LK_SMALL_INT_BITCODE?= $(firstword $(wildcard $(foreach framework_dir,${GNUSTEP_FRAMEWORK_DIRS},$(framework_dir)/LanguageKitCodeGen.framework/Versions/Current/Resources/MsgSendSmallInt.bc))) 

$(GNUSTEP_OBJ_INSTANCE_DIR)/%.st.bc : %.st
	@echo "Compiling Pragmatic Smalltalk file $< to LLVM bitcode ..."
	@edlc -c -f $< -o $@

ifneq ($(strip $(SMALLTALK_BITCODE_FILES)),)

# TODO: Decide whether we want relocatable code by looking at whether we are
# building a framework or an executable
$(GNUSTEP_OBJ_INSTANCE_DIR)/smalltalk.bc : $(SMALLTALK_BITCODE_FILES)
	@echo "Linking LLVM bitcodes from Pragmatic Smalltalk files ..."
	@llvm-ld -link-as-library -disable-internalize -o $@ $(SMALLTALK_BITCODE_FILES) $(LK_SMALL_INT_BITCODE)

# TODO: Load opts for the GNUstep runtime
$(GNUSTEP_OBJ_INSTANCE_DIR)/smalltalk.opt.bc : $(GNUSTEP_OBJ_INSTANCE_DIR)/smalltalk.bc
	@echo "Optimizing LLVM bitcode ..."
	@opt -O3 $< -o $@

$(GNUSTEP_OBJ_INSTANCE_DIR)/smalltalk.opt.s : $(GNUSTEP_OBJ_INSTANCE_DIR)/smalltalk.opt.bc 
	@echo "Compiling LLVM bitcode ..."
	@llc -relocation-model=pic -o $@ $<

$(GNUSTEP_OBJ_INSTANCE_DIR)/smalltalk.opt.o : $(GNUSTEP_OBJ_INSTANCE_DIR)/smalltalk.opt.s
	@echo "Assembling LLVM bitcode ..."
	@clang -c -O3 -o $@ $<

# Adding smalltalk.opt.o to _OBJ_FILES connects the above targets to the build.
$(GNUSTEP_INSTANCE)_OBJ_FILES+=$(GNUSTEP_OBJ_INSTANCE_DIR)/smalltalk.opt.o 

# Statically compiled Smalltalk code needs the LK runtime and the Smalltalk
# support libraries.
$(GNUSTEP_INSTANCE)_LDFLAGS+=-lLanguageKitRuntime -lSmalltalkSupport
endif


