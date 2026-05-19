COBC = cobc
COBFLAGS = -x -free

BINDIR = bin
SRCDIR = src

all: compile

compile:
	mkdir -p $(BINDIR)
	@echo "Compilation modules ETUDIANTS..."
	@for f in $(SRCDIR)/modules/ETUDIANTS/*.cob; do \
		n=$$(basename $$f .cob); \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f 2>/dev/null && echo "  ✓ $$n"; \
	done
	@echo "Compilation modules NOTES..."
	@for f in $(SRCDIR)/modules/NOTES/*.cob; do \
		n=$$(basename $$f .cob); \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f 2>/dev/null && echo "  ✓ $$n"; \
	done
	@echo "Compilation BATCH..."
	$(COBC) $(COBFLAGS) -o $(BINDIR)/BATCH_ECOLE $(SRCDIR)/batch/BATCH_ECOLE.cob 2>/dev/null && echo "  ✓ BATCH_ECOLE"
	@echo "Compilation terminee"

clean:
	rm -rf $(BINDIR)/*

run:
	./scripts/main.sh

status:
	@echo "=== STATUT ==="
	@echo "Etudiants: $$(wc -l < data/input/ETUDIANTS.DAT)"
	@echo "Notes: $$(wc -l < data/input/NOTES.DAT)"
	@echo "Binaires: $$(ls -1 bin/ | wc -l)"

.PHONY: all compile clean run status
