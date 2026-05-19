COBC = cobc
COBFLAGS = -x -free

BINDIR = bin
SRCDIR = src

all: compile

compile:
	mkdir -p $(BINDIR)
	@echo "Compilation modules CLIENTS..."
	@for f in $(SRCDIR)/modules/CLIENTS/*.cob; do \
		n=$$(basename $$f .cob); \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f 2>/dev/null && echo "  ✓ $$n"; \
	done
	@echo "Compilation modules COMPTES..."
	@for f in $(SRCDIR)/modules/COMPTES/*.cob; do \
		n=$$(basename $$f .cob); \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f 2>/dev/null && echo "  ✓ $$n"; \
	done
	@echo "Compilation modules TRANSACTIONS..."
	@for f in $(SRCDIR)/modules/TRANSACTIONS/*.cob; do \
		n=$$(basename $$f .cob); \
		$(COBC) $(COBFLAGS) -o $(BINDIR)/$$n $$f 2>/dev/null && echo "  ✓ $$n"; \
	done
	@echo "Compilation BATCH..."
	$(COBC) $(COBFLAGS) -o $(BINDIR)/BATCH_BANQUE $(SRCDIR)/batch/BATCH_BANQUE.cob 2>/dev/null && echo "  ✓ BATCH_BANQUE"
	@echo "Compilation terminee"

clean:
	rm -rf $(BINDIR)/*

run:
	./scripts/main.sh

.PHONY: all compile clean run
