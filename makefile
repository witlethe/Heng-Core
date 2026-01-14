# ------------------ COMPILE OPTIONS ----------------------

CXX ?= g++

CPPFLAGS += -Iinclude $(EXTRA)

CXXFLAGS += -std=c++20 -O2 -Wall -Wextra -Werror -fPIE

LDFLAGS += -pie

LDLIBS += -lstdc++fs

# ------------------ COMPILE OPTIONS ----------------------


# ----------------- OPTIONAL FEATURES ---------------------

SANITIZE 	?= 
PROFILE 	?= 
DEBUG 		?= 

ifeq ($(SANITIZE),address)
    CXXFLAGS += -fsanitize=address,undefined -fno-omit-frame-pointer -g -O1
    LDFLAGS  += -fsanitize=address,undefined
endif

ifeq ($(SANITIZE),thread)
    CXXFLAGS += -fsanitize=thread -g -O1
    LDFLAGS  += -fsanitize=thread
endif

ifeq ($(PROFILE),1)
    CXXFLAGS += -pg -g
    LDFLAGS  += -pg
endif

ifeq ($(DEBUG),1)
    CXXFLAGS += -O0 -g3 -DDEBUG
endif

# ----------------- OPTIONAL FEATURES ---------------------


# -------------- FILE SETS AND DIRECTORIES ----------------

SRC_DIR = src
BUILD_DIR = build

TEST_SRC = test_src
TEST_BUILD_DIR = test_build
TEST_EXE = $(TEST_BUILD_DIR)/test

INSTALL_DIR = /usr/local/bin
BIN = hc

TEST_SRCS_CXX = $(wildcard $(TEST_SRC)/*.cpp)
TEST_OBJ = $(patsubst $(TEST_SRC)/%.cpp, $(TEST_BUILD_DIR)/%.o, $(TEST_SRCS_CXX))

SRCS_CXX = $(wildcard $(SRC_DIR)/*.cpp)
SRCS_HXX = $(patsubst %.cpp, %.hpp, $(SRCS_CXX))

# Pattern matching to build object files
OBJ = $(patsubst $(SRC_DIR)/%.cpp, $(BUILD_DIR)/%.o, $(SRCS_CXX))

# -------------- FILE SETS AND DIRECTORIES ----------------


# -------------------- DEPENDENCIES -----------------------

.PHONY:all clean install testbin

all:$(BUILD_DIR) $(BIN) 


# ---- source program build
$(BUILD_DIR):
	mkdir -p $@

$(BIN): $(OBJ)
	$(CXX) $(LDFLAGS) $^ $(LDLIBS) -o $@

# object files depends on .cpp files
$(BUILD_DIR)/%.o:$(SRC_DIR)/%.cpp $(SRC_DIR)/%.hpp $(SRCS_HXX)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@
# ---- source program build


# ---- test program build
testbin:$(TEST_EXE)

$(TEST_BUILD_DIR):
	mkdir -p $@

# test .o files depends on .cpp files
$(TEST_BUILD_DIR)/%.o:$(TEST_SRC)/%.cpp | $(TEST_BUILD_DIR)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

# test bin depends on testobj files
$(TEST_EXE): $(TEST_OBJ)
	$(CXX) $(LDFLAGS) $^ $(LDLIBS) -o $@
# ---- test program build


install:
	install -m 0755 $(BIN) $(INSTALL_DIR)/$(BIN)

clean :
	rm -rf $(BUILD_DIR) $(TEST_BUILD_DIR) $(BIN)

test:
	nohup ./hc -bin /usr/bin/ls

# -------------------- DEPENDENCIES -----------------------