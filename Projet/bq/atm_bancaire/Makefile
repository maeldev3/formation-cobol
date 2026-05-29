# =====================================================
# MAKEFILE - ATM BANKING SYSTEM
# =====================================================

COBC = cobc
COBFLAGS = -x -free

BINDIR = bin
SRCDIR = src
DATADIR = data

all: clean compile

compile:
	@mkdir -p $(BINDIR)
	@mkdir -p data/temp
	@echo "========================================="
	@echo "Compilation ATM Banking System"
	@echo "========================================="
	@$(COBC) $(COBFLAGS) -o $(BINDIR)/ATM $(SRCDIR)/ATM.cob
	@if [ $$? -eq 0 ]; then \
		echo "  ✓ ATM compile avec succes"; \
	else \
		echo "  ✗ Erreur de compilation"; \
		exit 1; \
	fi
	@echo ""
	@echo "✅ Compilation terminee"

clean:
	@rm -rf $(BINDIR)/*
	@rm -rf data/temp/*
	@echo "✓ Nettoyage termine"

run:
	@./$(BINDIR)/ATM

init:
	@echo "Initialisation des donnees..."
	@mkdir -p data/input data/temp data/logs
	@echo "✅ Donnees initialisees"

status:
	@echo "========================================="
	@echo "STATUT ATM BANKING SYSTEM"
	@echo "========================================="
	@echo "Cartes:     $$(wc -l < data/input/CARTES.dat 2>/dev/null || echo 0)"
	@echo "Comptes:    $$(wc -l < data/input/COMPTES.dat 2>/dev/null || echo 0)"
	@echo "Transactions: $$(wc -l < data/input/TRANSACTIONS.dat 2>/dev/null || echo 0)"
	@echo "========================================="

test:
	@echo "Test du systeme ATM..."
	@echo "Carte test: 1234567890123456"
	@echo "PIN test: 1234"
	@echo ""
	@echo "Lancement de l'ATM..."
	@echo "1234567890123456" | $(BINDIR)/ATM || true

.PHONY: all compile clean run init status test
