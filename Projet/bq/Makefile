# Makefile - Bank Customer Management System
# GnuCOBOL, format fixe standard (pas de -free)
COBC     = cobc
SRC      = src
BIN      = bin
DATA     = data

.PHONY: all clean init run help

all: dirs $(BIN)/CUSTVAL.so $(BIN)/CUSTINIT $(BIN)/BANKCUST
	@echo ""
	@echo "Compilation reussie. Lancer: make init && make run"

dirs:
	@mkdir -p $(BIN) $(DATA)

$(BIN)/CUSTVAL.so: $(SRC)/CUSTVAL.cbl
	$(COBC) -m $< -o $@

$(BIN)/CUSTINIT: $(SRC)/CUSTINIT.cbl
	$(COBC) -x $< -o $@

$(BIN)/BANKCUST: $(SRC)/BANKCUST.cbl
	$(COBC) -x $< -o $@

init: $(BIN)/CUSTINIT
	./$(BIN)/CUSTINIT

run: $(BIN)/BANKCUST
	./$(BIN)/BANKCUST

clean:
	rm -rf $(BIN)/* $(DATA)/*.dat $(DATA)/*.txt
	@echo "Nettoyage termine."

help:
	@echo "Cibles disponibles:"
	@echo "  make all    - Compiler tout"
	@echo "  make init   - Initialiser la base de donnees"
	@echo "  make run    - Lancer le programme"
	@echo "  make clean  - Nettoyer les binaires et donnees"
