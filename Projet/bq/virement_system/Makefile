COBC = cobc
CFLAGS = -x -free -I src/
BINDIR = bin
SRCDIR = src
PROGS = AUTHENTIFIER SOLDE VIREMENT_INTERNE VIREMENT_EXTERNE HISTORIQUE LOGOUT
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
	rm -rf $(BINDIR) SESSION.DAT TEMP.DAT SQL_TMP.SQL

.PHONY: all clean init-db reset-db run
