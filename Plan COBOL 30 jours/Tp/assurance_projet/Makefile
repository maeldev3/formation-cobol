# Compilateur COBOL
COBC = cobc
COBFLAGS = -x -free

# Répertoires
SRCDIR = src
BINDIR = bin
MODULES_DIR = $(SRCDIR)/modules
BATCH_DIR = $(SRCDIR)/batch
REPORTS_DIR = $(SRCDIR)/reports

# Créer bin directory
$(shell mkdir -p $(BINDIR))

# Liste des programmes
PROGRAMS = $(BINDIR)/AJOUT_CLIENT \
           $(BINDIR)/MODIF_CLIENT \
           $(BINDIR)/RECHERCHE_CLIENT \
           $(BINDIR)/CREER_CONTRAT \
           $(BINDIR)/RESILIER_CONTRAT \
           $(BINDIR)/LISTE_CONTRATS \
           $(BINDIR)/DECLARER_SINISTRE \
           $(BINDIR)/TRAITER_SINISTRE \
           $(BINDIR)/SUIVI_SINISTRE \
           $(BINDIR)/INDEMNISER \
           $(BINDIR)/HISTORIQUE_PAIEMENT \
           $(BINDIR)/BATCH_QUOTIDIEN \
           $(BINDIR)/BATCH_HEBDOMADAIRE \
           $(BINDIR)/BATCH_MENSUEL \
           $(BINDIR)/RAPPORT_CONTRATS \
           $(BINDIR)/RAPPORT_SINISTRES \
           $(BINDIR)/RAPPORT_FINANCIER

all: $(PROGRAMS)

$(BINDIR)/%: $(MODULES_DIR)/CLIENTS/%.cob
	$(COBC) $(COBFLAGS) -o $@ $<

$(BINDIR)/%: $(MODULES_DIR)/CONTRATS/%.cob
	$(COBC) $(COBFLAGS) -o $@ $<

$(BINDIR)/%: $(MODULES_DIR)/SINISTRES/%.cob
	$(COBC) $(COBFLAGS) -o $@ $<

$(BINDIR)/%: $(MODULES_DIR)/PAIEMENTS/%.cob
	$(COBC) $(COBFLAGS) -o $@ $<

$(BINDIR)/BATCH_%: $(BATCH_DIR)/BATCH_%.cob
	$(COBC) $(COBFLAGS) -o $@ $<

$(BINDIR)/RAPPORT_%: $(REPORTS_DIR)/RAPPORT_%.cob
	$(COBC) $(COBFLAGS) -o $@ $<

clean:
	rm -f $(BINDIR)/*

.PHONY: all clean
EOF
