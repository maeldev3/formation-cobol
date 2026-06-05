COBOL=cobc

SRC=src/main.cbl
BIN=bin/atm-system

build:
	mkdir -p bin
	$(COBOL) -x -free $(SRC) -o $(BIN)

run:
	./$(BIN)

clean:
	rm -rf bin/*

rebuild: clean build
