COBC = cobc
COBFLAGS = -x -free

BINDIR = bin
SRCDIR = src

all: clean compile

compile:
	@mkdir -p $(BINDIR) data/temp
	@echo "========================================="
	@echo "Compilation Systeme Bancaire Corporate V3"
	@echo "========================================="
	@echo ""
	@echo "[1/7] Compilation modules CLIENTS..."
	@for f in $(SRCDIR)/modules/CLIENTS/*.cob; do \
		n=$$(basename $$f .cob); \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f 2>/dev/null && echo "  ✓ $$n" || echo "  ✗ $$n"; \
	done
	@echo ""
	@echo "[2/7] Compilation modules COMPTES..."
	@for f in $(SRCDIR)/modules/COMPTES/*.cob; do \
		n=$$(basename $$f .cob); \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f 2>/dev/null && echo "  ✓ $$n" || echo "  ✗ $$n"; \
	done
	@echo ""
	@echo "[3/7] Compilation modules CARTES..."
	@for f in $(SRCDIR)/modules/CARTES/*.cob; do \
		n=$$(basename $$f .cob); \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f 2>/dev/null && echo "  ✓ $$n" || echo "  ✗ $$n"; \
	done
	@echo ""
	@echo "[4/7] Compilation modules TRANSACTIONS..."
	@for f in $(SRCDIR)/modules/TRANSACTIONS/*.cob; do \
		n=$$(basename $$f .cob); \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f 2>/dev/null && echo "  ✓ $$n" || echo "  ✗ $$n"; \
	done
	@echo ""
	@echo "[5/7] Compilation modules CREDITS..."
	@for f in $(SRCDIR)/modules/CREDITS/*.cob; do \
		n=$$(basename $$f .cob); \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f 2>/dev/null && echo "  ✓ $$n" || echo "  ✗ $$n"; \
	done
	@echo ""
	@echo "[6/7] Compilation modules AGENCES..."
	@for f in $(SRCDIR)/modules/AGENCES/*.cob; do \
		n=$$(basename $$f .cob); \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f 2>/dev/null && echo "  ✓ $$n" || echo "  ✗ $$n"; \
	done
	@echo ""
	@echo "[7/7] Compilation modules UTILISATEURS..."
	@for f in $(SRCDIR)/modules/UTILISATEURS/*.cob; do \
		n=$$(basename $$f .cob); \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f 2>/dev/null && echo "  ✓ $$n" || echo "  ✗ $$n"; \
	done
	@echo ""
	@echo "[8/8] Compilation BATCH..."
	@for f in $(SRCDIR)/batch/*.cob; do \
		n=$$(basename $$f .cob); \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f 2>/dev/null && echo "  ✓ $$n" || echo "  ✗ $$n"; \
	done
	@echo ""
	@echo "✅ Compilation terminee"

clean:
	@rm -rf $(BINDIR)/*
	@echo "✓ Nettoyage termine"

run:
	@./scripts/main.sh

status:
	@echo "========================================="
	@echo "STATUT DU SYSTEME BANCAIRE"
	@echo "========================================="
	@echo "Clients:     $$(wc -l < data/input/CLIENTS.dat 2>/dev/null || echo 0)"
	@echo "Comptes:     $$(wc -l < data/input/COMPTES.dat 2>/dev/null || echo 0)"
	@echo "Cartes:      $$(wc -l < data/input/CARTES.dat 2>/dev/null || echo 0)"
	@echo "Transactions:$$(wc -l < data/input/TRANSACTIONS.dat 2>/dev/null || echo 0)"
	@echo "Credits:     $$(wc -l < data/input/CREDITS.dat 2>/dev/null || echo 0)"
	@echo "Agences:     $$(wc -l < data/input/AGENCES.dat 2>/dev/null || echo 0)"
	@echo "Utilisateurs:$$(wc -l < data/input/UTILISATEURS.dat 2>/dev/null || echo 0)"
	@echo "Binaires:    $$(ls -1 bin/ | wc -l 2>/dev/null || echo 0)"
	@echo "========================================="

.PHONY: all compile clean run status
