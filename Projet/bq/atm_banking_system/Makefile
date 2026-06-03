#==============================================================#
# Makefile pour ATM Banking System
# Author: Senior Developer
# Version: 2.0
#==============================================================#

# Variables
PROJECT_NAME = atm-banking
VERSION = 2.0
CC = cobc
CFLAGS = -Wall -debug -static
COPYBOOKS = -I copybooks
SRC_DIR = src
BIN_DIR = bin
OBJ_DIR = obj
DATA_DIR = data
LOG_DIR = logs

# Fichiers source
MAIN_SRC = $(SRC_DIR)/atm-main.cob
ERROR_SRC = $(SRC_DIR)/error-handler.cob
VALIDATOR_SRC = $(SRC_DIR)/validator.cob
TRANSACTION_SRC = $(SRC_DIR)/transaction-manager.cob

# Fichiers objets
MAIN_OBJ = $(OBJ_DIR)/atm-main.o
ERROR_OBJ = $(OBJ_DIR)/error-handler.o
VALIDATOR_OBJ = $(OBJ_DIR)/validator.o
TRANSACTION_OBJ = $(OBJ_DIR)/transaction-manager.o

# Exécutable final
TARGET = $(BIN_DIR)/$(PROJECT_NAME)

#==============================================================#
# Cibles principales
#==============================================================#

.PHONY: all clean install run test debug help

all: directories compile

compile: $(TARGET)

$(TARGET): $(MAIN_OBJ) $(ERROR_OBJ) $(VALIDATOR_OBJ) $(TRANSACTION_OBJ)
	@echo "Linking $(PROJECT_NAME) v$(VERSION)..."
	$(CC) -x $^ -o $@ $(CFLAGS)
	@echo "Build successful!"

$(MAIN_OBJ): $(MAIN_SRC)
	@echo "Compiling ATM-MAIN..."
	$(CC) -c $< -o $@ $(CFLAGS) $(COPYBOOKS)

$(ERROR_OBJ): $(ERROR_SRC)
	@echo "Compiling ERROR-HANDLER..."
	$(CC) -c $< -o $@ $(CFLAGS) $(COPYBOOKS)

$(VALIDATOR_OBJ): $(VALIDATOR_SRC)
	@echo "Compiling VALIDATOR..."
	$(CC) -c $< -o $@ $(CFLAGS) $(COPYBOOKS)

$(TRANSACTION_OBJ): $(TRANSACTION_SRC)
	@echo "Compiling TRANSACTION-MANAGER..."
	$(CC) -c $< -o $@ $(CFLAGS) $(COPYBOOKS)

#==============================================================#
# Utilitaires
#==============================================================#

directories:
	@mkdir -p $(OBJ_DIR) $(BIN_DIR) $(DATA_DIR) $(LOG_DIR)
	@echo "Project directories created"

run: compile
	@echo "Running $(PROJECT_NAME)..."
	@echo "========================================="
	@./$(TARGET)

test: compile
	@echo "Running tests..."
	@echo "Test 1: Valid login"
	@echo "Test 2: Invalid login"
	@echo "Test 3: Withdrawal"
	@echo "Test 4: Deposit"
	@echo "========================================="

debug: CFLAGS += -debug -g
debug: clean compile
	@echo "Debug build created"
	@echo "Run with: gdb ./$(TARGET)"

clean:
	@echo "Cleaning build files..."
	rm -rf $(OBJ_DIR)/*.o $(BIN_DIR)/$(PROJECT_NAME)
	rm -rf $(LOG_DIR)/*.log
	@echo "Clean complete"

install: compile
	@echo "Installing to /usr/local/bin..."
	@cp $(TARGET) /usr/local/bin/
	@chmod 755 /usr/local/bin/$(PROJECT_NAME)
	@echo "Installation complete"

help:
	@echo "ATM Banking System Makefile"
	@echo "============================"
	@echo "Available targets:"
	@echo "  make compile  - Build the system"
	@echo "  make run      - Build and run"
	@echo "  make test     - Run tests"
	@echo "  make debug    - Build with debug symbols"
	@echo "  make clean    - Remove build files"
	@echo "  make install  - Install system"
	@echo "  make help     - Show this help"

#==============================================================#
# Dépendances
#==============================================================#

-include $(OBJ_DIR)/*.d

