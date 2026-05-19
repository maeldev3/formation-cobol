#====================================================================
# SYSTEME ASSURANCE - COBOL MAKEFILE
#====================================================================

# Compilateur et options
COBC = cobc
COBFLAGS = -x -free -Wall

# Répertoires
SRCDIR = src
BINDIR = bin
DATADIR = data

# Couleurs pour les logs
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
NC = \033[0m

#====================================================================
# MODULES
#====================================================================

MODULES_CLIENTS = AJOUT_CLIENT LISTER_CLIENTS RECHERCHE_CLIENT
MODULES_CONTRATS = CREER_CONTRAT LISTER_CONTRATS
MODULES_SINISTRES = DECLARER_SINISTRE LISTER_SINISTRES TRAITER_SINISTRE
MODULES_BATCH = BATCH_QUOTIDIEN

#====================================================================
# TARGETS
#====================================================================

.PHONY: all help clean compile run status

all: compile
	@echo "$(GREEN)✓ Compilation terminée$(NC)"

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets disponibles:"
	@echo "  all        - Compiler tous les modules"
	@echo "  compile    - Compiler uniquement"
	@echo "  run        - Lancer l'application"
	@echo "  clean      - Nettoyer les binaires"
	@echo "  status     - Voir l'état du projet"

#====================================================================
# COMPILATION
#====================================================================

compile: compile_clients compile_contrats compile_sinistres compile_batch
	@mkdir -p $(BINDIR)
	@echo "$(GREEN)✓ Tous les modules compilés$(NC)"

compile_clients:
	@echo "$(YELLOW)Compilation modules CLIENTS...$(NC)"
	@mkdir -p $(BINDIR)
	@for module in $(MODULES_CLIENTS); do \
		if [ -f $(SRCDIR)/modules/CLIENTS/$$module.cob ]; then \
			$(COBC) $(COBFLAGS) -o $(BINDIR)/$$module $(SRCDIR)/modules/CLIENTS/$$module.cob 2>/dev/null && echo "  ✓ $$module" || echo "  ✗ $$module"; \
		fi \
	done

compile_contrats:
	@echo "$(YELLOW)Compilation modules CONTRATS...$(NC)"
	@mkdir -p $(BINDIR)
	@for module in $(MODULES_CONTRATS); do \
		if [ -f $(SRCDIR)/modules/CONTRATS/$$module.cob ]; then \
			$(COBC) $(COBFLAGS) -o $(BINDIR)/$$module $(SRCDIR)/modules/CONTRATS/$$module.cob 2>/dev/null && echo "  ✓ $$module" || echo "  ✗ $$module"; \
		fi \
	done

compile_sinistres:
	@echo "$(YELLOW)Compilation modules SINISTRES...$(NC)"
	@mkdir -p $(BINDIR)
	@for module in $(MODULES_SINISTRES); do \
		if [ -f $(SRCDIR)/modules/SINISTRES/$$module.cob ]; then \
			$(COBC) $(COBFLAGS) -o $(BINDIR)/$$module $(SRCDIR)/modules/SINISTRES/$$module.cob 2>/dev/null && echo "  ✓ $$module" || echo "  ✗ $$module"; \
		fi \
	done

compile_batch:
	@echo "$(YELLOW)Compilation modules BATCH...$(NC)"
	@mkdir -p $(BINDIR)
	@for module in $(MODULES_BATCH); do \
		if [ -f $(SRCDIR)/batch/$$module.cob ]; then \
			$(COBC) $(COBFLAGS) -o $(BINDIR)/$$module $(SRCDIR)/batch/$$module.cob 2>/dev/null && echo "  ✓ $$module" || echo "  ✗ $$module"; \
		fi \
	done

#====================================================================
# EXECUTION
#====================================================================

run:
	@echo "$(YELLOW)Lancement de l'application...$(NC)"
	@./scripts/main.sh

#====================================================================
# UTILITAIRES
#====================================================================

clean:
	@echo "$(YELLOW)Nettoyage des binaires...$(NC)"
	@rm -rf $(BINDIR)/*
	@echo "$(GREEN)✓ Nettoyage terminé$(NC)"

status:
	@echo "$(YELLOW)Statut du projet:$(NC)"
	@echo "  Modules compilés: $$(ls -1 $(BINDIR) 2>/dev/null | wc -l)"
	@echo "  Données clients: $$(wc -l < $(DATADIR)/input/CLIENTS.DAT 2>/dev/null || echo 0)"
	@echo "  Données contrats: $$(wc -l < $(DATADIR)/input/CONTRATS.DAT 2>/dev/null || echo 0)"
	@echo "  Données sinistres: $$(wc -l < $(DATADIR)/input/SINISTRES.DAT 2>/dev/null || echo 0)"
