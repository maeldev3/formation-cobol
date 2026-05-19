COBC = cobc
COBFLAGS = -x -free

BINDIR = bin
SRCDIR = src

all: compile

compile:
	mkdir -p $(BINDIR)
	@echo "Compilation modules PATIENTS..."
	@for f in $(SRCDIR)/modules/PATIENTS/*.cob; do \
		n=$$(basename $$f .cob); \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f 2>/dev/null && echo "  ✓ $$n"; \
	done
	@echo "Compilation modules CONSULTATIONS..."
	@for f in $(SRCDIR)/modules/CONSULTATIONS/*.cob; do \
		n=$$(basename $$f .cob); \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f 2>/dev/null && echo "  ✓ $$n"; \
	done
	@echo "Compilation modules FACTURES..."
	@for f in $(SRCDIR)/modules/FACTURES/*.cob; do \
		n=$$(basename $$f .cob); \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f 2>/dev/null && echo "  ✓ $$n"; \
	done
	@echo "Compilation BATCH..."
	$(COBC) $(COBFLAGS) -o $(BINDIR)/BATCH_HOPITAL $(SRCDIR)/batch/BATCH_HOPITAL.cob 2>/dev/null && echo "  ✓ BATCH_HOPITAL"
	@echo "Compilation terminee"

clean:
	rm -rf $(BINDIR)/*

run:
	./scripts/main.sh

.PHONY: all compile clean run
