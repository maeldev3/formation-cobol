# ================================================================
# Makefile - ATM Banking System en COBOL
# Compilateur : GnuCOBOL (cobc)
# Usage : make init && make run
# ================================================================

CC = cobc
CFLAGS = -x -free -Wall
SRCDIR = src
DATADIR = data
BINDIR = bin

# Cibles principales
all: dirs $(BINDIR)/atm-init $(BINDIR)/atm-main

# Création des répertoires
dirs:
	@mkdir -p $(DATADIR) $(BINDIR)
	@echo "[INFO] Répertoires créés."

# Compilation ATM-INIT
$(BINDIR)/atm-init: $(SRCDIR)/ATM-INIT.cbl
	@echo "[COMPILE] ATM-INIT..."
	$(CC) $(CFLAGS) -o $@ $<
	@echo "[OK] atm-init compilé."

# Compilation ATM-MAIN (programme principal)
$(BINDIR)/atm-main: $(SRCDIR)/ATM-MAIN.cbl
	@echo "[COMPILE] ATM-MAIN..."
	$(CC) $(CFLAGS) -o $@ $<
	@echo "[OK] atm-main compilé."

# Initialisation de la base de données
init: $(BINDIR)/atm-init
	@echo "[INIT] Initialisation des fichiers de données..."
	cd $(BINDIR) && ./atm-init
	@echo "[OK] Base de données initialisée."

# Lancement du système ATM
run: $(BINDIR)/atm-main
	@echo ""
	@echo "======================================================"
	@echo "  Démarrage du Système ATM Bancaire..."
	@echo "======================================================"
	@echo ""
	cd $(BINDIR) && ./atm-main

# Lancer depuis zéro (init + run)
start: all init run

# Nettoyage des binaires
clean:
	@rm -f $(BINDIR)/*
	@echo "[OK] Binaires supprimés."

# Nettoyage complet (binaires + données)
clean-all: clean
	@rm -f $(DATADIR)/*.DAT $(DATADIR)/*.dat
	@echo "[OK] Données supprimées."

# Compilation avec format fixe (si nécessaire)
fixed: dirs
	$(CC) -x -fixed -Wall -o $(BINDIR)/atm-init $(SRCDIR)/ATM-INIT.cbl
	$(CC) -x -fixed -Wall -o $(BINDIR)/atm-main $(SRCDIR)/ATM-MAIN.cbl

# Aide
help:
	@echo ""
	@echo "  COMMANDES DISPONIBLES :"
	@echo ""
	@echo "  make all       - Compiler tous les programmes"
	@echo "  make init      - Initialiser la base de données"
	@echo "  make run       - Lancer le système ATM"
	@echo "  make start     - Tout faire en une seule commande"
	@echo "  make clean     - Supprimer les binaires"
	@echo "  make clean-all - Supprimer tout (binaires + données)"
	@echo "  make fixed     - Compiler en format fixe COBOL"
	@echo ""

.PHONY: all dirs init run start clean clean-all help fixed
