COBC = cobc
CFLAGS = -x -free -I src/
BINDIR = bin
SRCDIR = src
PROGS = AUTHENTIFIER SOLDE RETRAIT DEPOT HISTORIQUE LOGOUT
TARGETS = $(addprefix $(BINDIR)/, $(PROGS))

all: $(TARGETS)
	@echo "Compilation terminée."

$(BINDIR)/%: $(SRCDIR)/%.cob | $(BINDIR)
	$(COBC) $(CFLAGS) -o $@ $<

$(BINDIR):
	mkdir -p $@

init-db:
	@if [ -f scripts/init_db.sh ]; then \
		cd scripts && ./init_db.sh; \
	else \
		echo "Erreur: scripts/init_db.sh introuvable"; \
		exit 1; \
	fi

reset-db:
	@if [ -f scripts/reset_db.sh ]; then \
		cd scripts && ./reset_db.sh; \
	else \
		echo "Erreur: scripts/reset_db.sh introuvable"; \
		exit 1; \
	fi

run: $(TARGETS)
	@if [ -f menu.sh ]; then \
		./menu.sh; \
	else \
		echo "Erreur: menu.sh introuvable"; \
		exit 1; \
	fi
reset-db:
	@if [ -f scripts/reset_db.sh ]; then \
		cd scripts && ./reset_db.sh; \
	else \
		echo "Erreur: scripts/reset_db.sh introuvable"; \
	fi

clean:
	rm -rf $(BINDIR) SESSION.DAT TEMP.DAT SQL_TMP.DAT

.PHONY: all clean init-db reset-db run