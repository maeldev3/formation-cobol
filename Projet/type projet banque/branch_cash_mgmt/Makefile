# Makefile pour Branch Cash Management System

CC = cobc
CFLAGS = -x
OBJ_DIR = obj
SRC_DIR = src
BIN_DIR = bin

all: directories compile

directories:
    mkdir -p $(OBJ_DIR) $(BIN_DIR) data reports

compile:
    $(CC) -c $(SRC_DIR)/CASHIN.cbl -o $(OBJ_DIR)/CASHIN.o
    $(CC) -c $(SRC_DIR)/CASHOUT.cbl -o $(OBJ_DIR)/CASHOUT.o
    $(CC) -c $(SRC_DIR)/CASHCTRL.cbl -o $(OBJ_DIR)/CASHCTRL.o
    $(CC) -c $(SRC_DIR)/CLOSEDAY.cbl -o $(OBJ_DIR)/CLOSEDAY.o
    $(CC) $(CFLAGS) $(SRC_DIR)/CASHMAIN.cbl $(OBJ_DIR)/CASHIN.o \
          $(OBJ_DIR)/CASHOUT.o $(OBJ_DIR)/CASHCTRL.o \
          $(OBJ_DIR)/CLOSEDAY.o -o $(BIN_DIR)/CASHMAIN

clean:
    rm -f $(OBJ_DIR)/*.o $(BIN_DIR)/CASHMAIN

run: all
    $(BIN_DIR)/CASHMAIN

.PHONY: all compile clean run
