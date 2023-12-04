# =============================================================================
#
# Philipp Schubert
#
#    Copyright (C) 2017
#    Software Engineering Group
#    Heinz Nixdorf Institut
#    University of Paderborn
#    philipp.schubert@upb.de
#
# =============================================================================
#

UNAME := $(shell uname -s)
ASAN := off # on, off

###############################################################################
# Compiler Settings                                                           #
###############################################################################

# -- Compiler
CXX = g++

# -- Overall Options
CXXFLAGS += -pipe

# -- C++ Language Options
CXXFLAGS = -std=c++14
CXXFLAGS += -pedantic
CXXFLAGS += -Wall
CXXFLAGS += -Wextra
CXXFLAGS += -stdlib=libstdc++
CXXFLAGS += -Wno-unknown-warning-option
ifeq ($(CXX), clang++)
	CXXFLAGS += -Qunused-arguments
endif

# -- Optimization Options
CXXFLAGS += -O0
#CXXFLAGS += -Ofast
#CXXFLAGS += -march=native

# -- Debugging Options
ifeq ($(UNAME), Linux)
	CXXFLAGS += -g -ggdb3
else
	CXXFLAGS += -g
endif

# -- Preprocessor Options
CPPFLAGS += -MMD
CPPFLAGS += -MP

# -- Linker flags
LDFLAGS :=
LDLIBS :=
#LDFLAGS += #-shared

# -- Code Generation Options
#CXXFLAGS += #-fPIC

# -- Sanitizer flags
ifeq ($(ASAN), on)
	LDFLAGS += -fsanitize=address

	ifeq ($(CXX), clang++)
		CXXFLAGS += -fsanitize=address -fsanitize=undefined
		LDFLAGS += -fsanitize=address
	endif
	ifeq ($(CXX), g++)
		CXXFLAGS += -fsanitize=address -fsanitize=undefined
		LDFLAGS += -fsanitize=address
	endif
endif


###############################################################################
# Function Definitions                                                        #
###############################################################################

# -- Recusive Wildcard
# doc: tbd
recwildcard=$(wildcard $1$2)\
	$(foreach d,$(wildcard $1*),$(call recwildcard,$d/,$2))


###############################################################################
# Specify Some File and Directory Paths                                       #
###############################################################################

EXE = t # <-- change this

BIN = bin/
OBJDIR = obj/
DOC = doc/
SRC = src/
ALL_SRC = $(sort $(dir $(call recwildcard,$(SRC)**/*/)))
VPATH = $(SRC):$(ALL_SRC)
OBJ = $(addprefix\
	$(OBJDIR),$(notdir $(patsubst %.cpp,%.o,$(call recwildcard,src/,*.cpp))))
DEP = $(OBJ:.o=.d)
AUTOFORMAT_SCRIPT := misc/format_src_code.py


###############################################################################
# Targets and Rules                                                           #
###############################################################################

.PHONY: all

all: $(OBJDIR) $(BIN) $(BIN)$(EXE)

-include $(DEP)

$(OBJDIR):
	mkdir $@

$(BIN):
	mkdir $@

release: CFLAGS += -O2 -DNDEBUG
release: clean
release: $(BIN)$(EXE)

$(BIN)$(EXE): $(OBJ)
	$(CXX) $(CXXFLAGS) $^ $(MATH_LIBS) -o $@
	@echo "done ;-)"

$(OBJDIR)%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $< -o $@

.PHONY: doc
	# Create the code documentation
doc:
	@echo "Building the documentation of the source code ..."
	cd $(SRC); \
		doxygen doxy_config.conf

.PHONY: open_doc
open_doc:
	$$BROWSER $(DOC)/html/index.html || open $(DOC)/html/index.html

.PHONY: format
format:
	@echo "Formatting the projects source code using clang-format ..."
	python3 $(AUTOFORMAT_SCRIPT)

.PHONY: clean
clean:
	-$(RM) -rfv $(BIN)
	-$(RM) -rfv $(OBJDIR)
	-$(RM) -rfv $(DOC)

# vim: ft=make ts=4
