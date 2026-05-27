COBC = cobc
COBFLAGS = -x -free

BINDIR = bin
SRCDIR = src

all: clean compile

compile:
	mkdir -p $(BINDIR)
	@echo "Compilation modules ETUDIANTS..."
	@for f in $(SRCDIR)/modules/ETUDIANTS/*.cob; do \
		n=$$(basename $$f .cob); \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f 2>/dev/null && echo "  ✓ $$n" || echo "  ✗ $$n"; \
	done
	@echo "Compilation modules NOTES..."
	@for f in $(SRCDIR)/modules/NOTES/*.cob; do \
		n=$$(basename $$f .cob); \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f 2>/dev/null && echo "  ✓ $$n" || echo "  ✗ $$n"; \
	done
	@echo "Compilation BATCH..."
	$(COBC) $(COBFLAGS) -o $(BINDIR)/BATCH_ECOLE $(SRCDIR)/batch/BATCH_ECOLE.cob 2>/dev/null && echo "  ✓ BATCH_ECOLE" || echo "  ✗ BATCH_ECOLE"
	@echo "Compilation terminee"

# Nettoyer et tout compiler
clean:
	rm -rf $(BINDIR)/*
	@echo "✓ Nettoyage termine"

# Compiler avec debug (pour voir les erreurs)
debug:
	mkdir -p $(BINDIR)
	@for f in $(SRCDIR)/modules/ETUDIANTS/*.cob; do \
		n=$$(basename $$f .cob); \
		echo "Compilation $$n..."; \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f; \
	done
	@for f in $(SRCDIR)/modules/NOTES/*.cob; do \
		n=$$(basename $$f .cob); \
		echo "Compilation $$n..."; \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f; \
	done
	$(COBC) $(COBFLAGS) -o $(BINDIR)/BATCH_ECOLE $(SRCDIR)/batch/BATCH_ECOLE.cob

run:
	./scripts/main.sh

status:
	@echo "=== BINAIRES COMPILES ==="
	@ls -la $(BINDIR)/ 2>/dev/null || echo "Aucun binaire (lancez 'make compile')"
	@echo ""
	@echo "=== FICHIERS SOURCES ==="
	@echo "ETUDIANTS: $$(ls -1 $(SRCDIR)/modules/ETUDIANTS/*.cob 2>/dev/null | wc -l)"
	@echo "NOTES: $$(ls -1 $(SRCDIR)/modules/NOTES/*.cob 2>/dev/null | wc -l)"

.PHONY: all compile clean debug run status