# Makefile pour le système d'épargne
COBC = cobc
CFLAGS = -x -free -I src/
BINDIR = bin
SRCDIR = src
PROGS = AUTHENTIFIER SOLDE DEPOT RETRAIT CALCUL_INTERETS HISTORIQUE
TARGETS = $(addprefix $(BINDIR)/, $(PROGS))

all: $(TARGETS)
	@echo "Compilation terminée."

$(BINDIR)/%: $(SRCDIR)/%.cob | $(BINDIR)
	$(COBC) $(CFLAGS) -o $@ $<

$(BINDIR):
	mkdir -p $@

init-db:
	@cd scripts && ./init_db.sh

reset-db:
	@cd scripts && ./reset_db.sh

run: $(TARGETS)
	@./menu.sh

clean:
	rm -rf $(BINDIR) SESSION.DAT /tmp/TEMP.DAT /tmp/SQL_TMP.SQL

.PHONY: all clean init-db reset-db run
