# ==================================================
# Projet : Gestion RH COBOL + SQLite
# Auteur : DEV
# Version : 2.0
# ==================================================

# --------------------------------------------------
# COMPILATEUR ET OPTIONS
# --------------------------------------------------
COBOL = cobc
FLAGS = -x
DB_PATH = data/rh.db

# --------------------------------------------------
# RÉPERTOIRES
# --------------------------------------------------
BIN_DIR = bin
MODULES_DIR = modules
TEMP_DIR = temp

# --------------------------------------------------
# SOURCES PAR MODULE
# --------------------------------------------------
# Authentification
AUTH_SRC = modules/auth/authentifier.cob

# Départements
DEPARTEMENT_SRC = modules/departements/ajouter-departement.cob
DEPARTEMENT_LISTE_SRC = modules/departements/lister-departements.cob
DEPARTEMENT_MODIFIER_SRC = modules/departements/modifier-departement.cob
DEPARTEMENT_SUPPRIMER_SRC = modules/departements/supprimer-departement.cob

# Postes
POSTE_SRC = modules/postes/ajouter-poste.cob
POSTE_LISTE_SRC = modules/postes/lister-postes.cob
POSTE_MODIFIER_SRC = modules/postes/modifier-poste.cob
POSTE_SUPPRIMER_SRC = modules/postes/supprimer-poste.cob

# Employés
EMPLOYE_SRC = modules/employes/ajouter-employe.cob
EMPLOYE_LISTE_SRC = modules/employes/lister-employes.cob
EMPLOYE_MODIFIER_SRC = modules/employes/modifier-employe.cob

# Paie
PAIE_CALCULER_SRC = modules/paie/calculer-paie.cob
PAIE_LISTER_SRC = modules/paie/lister-paie.cob
PAIE_RAPPORT_SRC = modules/paie/rapport-paie.cob

# Présence
PRESENCE_AJOUTER_SRC = modules/presence/ajouter-presence.cob
PRESENCE_LISTE_SRC = modules/presence/lister-presence.cob

# Congés
CONGE_DEMANDE_SRC = modules/conges/demande-conge.cob
CONGE_LISTE_SRC = modules/conges/lister-conge.cob
CONGE_VALIDER_SRC = modules/conges/valider-conge.cob

# Rapport
RAPPORT_MENSUEL_SRC = modules/rapport/rapport-mensuel.cob
USER_SRC = modules/users/ajouter-utilisateur.cob
USER_LISTE_SRC = modules/users/lister-utilisateurs.cob
USER_MODIFIER_SRC = modules/users/modifier-utilisateur.cob
USER_SUPPRIMER_SRC = modules/users/supprimer-utilisateur.cob
# Menu
MENU_RH_SRC = modules/menu/menu-rh.cob

# --------------------------------------------------
# BINAIRES (générés automatiquement)
# --------------------------------------------------
AUTH_BIN = $(BIN_DIR)/login
DEPARTEMENT_BIN = $(BIN_DIR)/departement
DEPARTEMENT_LISTE_BIN = $(BIN_DIR)/departement-liste
DEPARTEMENT_MODIFIER_BIN = $(BIN_DIR)/departement-modifier
DEPARTEMENT_SUPPRIMER_BIN = $(BIN_DIR)/departement-supprimer
POSTE_BIN = $(BIN_DIR)/poste
POSTE_LISTE_BIN = $(BIN_DIR)/poste-liste
POSTE_MODIFIER_BIN = $(BIN_DIR)/poste-modifier
POSTE_SUPPRIMER_BIN = $(BIN_DIR)/poste-supprimer
EMPLOYE_BIN = $(BIN_DIR)/employe
EMPLOYE_LISTE_BIN = $(BIN_DIR)/employe-liste
EMPLOYE_MODIFIER_BIN = $(BIN_DIR)/employe-modifier
PAIE_CALCULER_BIN = $(BIN_DIR)/calculer-paie
PAIE_LISTER_BIN = $(BIN_DIR)/lister-paie
PAIE_RAPPORT_BIN = $(BIN_DIR)/rapport-paie
PRESENCE_AJOUTER_BIN = $(BIN_DIR)/presence-ajouter
PRESENCE_LISTE_BIN = $(BIN_DIR)/presence-liste
CONGE_DEMANDE_BIN = $(BIN_DIR)/conge-demande
CONGE_LISTE_BIN = $(BIN_DIR)/conge-liste
CONGE_VALIDER_BIN = $(BIN_DIR)/conge-valider
RAPPORT_MENSUEL_BIN = $(BIN_DIR)/rapport-mensuel
MENU_RH_BIN = $(BIN_DIR)/menu-rh


USER_BIN = $(BIN_DIR)/user
USER_LISTE_BIN = $(BIN_DIR)/user-liste
USER_MODIFIER_BIN = $(BIN_DIR)/user-modifier
USER_SUPPRIMER_BIN = $(BIN_DIR)/user-supprimer
# --------------------------------------------------
# RÈGLES PRINCIPALES
# --------------------------------------------------
.PHONY: all clean rebuild run run-all help

all: $(BIN_DIR) \
     auth \
     departement departement-liste departement-modifier departement-supprimer \
     poste poste-liste poste-modifier poste-supprimer \
     employe employe-liste employe-modifier \
     paie-calculer paie-lister paie-rapport \
     presence-ajouter presence-liste \
     conge-demande conge-liste conge-valider \
     rapport-mensuel \
     menu-rh \
	 dashboard \
     export-employes export-paie export-conges \
	 user user-liste user-modifier user-supprimer

# Création du répertoire bin
$(BIN_DIR):
	mkdir -p $(BIN_DIR)
	mkdir -p $(TEMP_DIR)

# --------------------------------------------------
# RÈGLE GÉNÉRIQUE DE COMPILATION
# --------------------------------------------------
define compile_rule
$(1): $(2)
	@echo "🔨 Compilation de $$<..."
	$(COBOL) $(FLAGS) $$< -o $$@
	@echo "✅ $$@ créé avec succès"
endef

# --------------------------------------------------
# RÈGLES SPÉCIFIQUES PAR MODULE
# --------------------------------------------------
# Authentification
$(AUTH_BIN): $(AUTH_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

# Départements
$(DEPARTEMENT_BIN): $(DEPARTEMENT_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

$(DEPARTEMENT_LISTE_BIN): $(DEPARTEMENT_LISTE_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

$(DEPARTEMENT_MODIFIER_BIN): $(DEPARTEMENT_MODIFIER_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

$(DEPARTEMENT_SUPPRIMER_BIN): $(DEPARTEMENT_SUPPRIMER_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

# Postes
$(POSTE_BIN): $(POSTE_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

$(POSTE_LISTE_BIN): $(POSTE_LISTE_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

$(POSTE_MODIFIER_BIN): $(POSTE_MODIFIER_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

$(POSTE_SUPPRIMER_BIN): $(POSTE_SUPPRIMER_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

# Employés
$(EMPLOYE_BIN): $(EMPLOYE_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

$(EMPLOYE_LISTE_BIN): $(EMPLOYE_LISTE_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

$(EMPLOYE_MODIFIER_BIN): $(EMPLOYE_MODIFIER_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

# Paie
$(PAIE_CALCULER_BIN): $(PAIE_CALCULER_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

$(PAIE_LISTER_BIN): $(PAIE_LISTER_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

$(PAIE_RAPPORT_BIN): $(PAIE_RAPPORT_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

# Présence
$(PRESENCE_AJOUTER_BIN): $(PRESENCE_AJOUTER_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

$(PRESENCE_LISTE_BIN): $(PRESENCE_LISTE_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

# Congés
$(CONGE_DEMANDE_BIN): $(CONGE_DEMANDE_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

$(CONGE_LISTE_BIN): $(CONGE_LISTE_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

$(CONGE_VALIDER_BIN): $(CONGE_VALIDER_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

# Rapport
$(RAPPORT_MENSUEL_BIN): $(RAPPORT_MENSUEL_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

# Menu
$(MENU_RH_BIN): $(MENU_RH_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@
$(USER_BIN): $(USER_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

$(USER_LISTE_BIN): $(USER_LISTE_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

$(USER_MODIFIER_BIN): $(USER_MODIFIER_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@

$(USER_SUPPRIMER_BIN): $(USER_SUPPRIMER_SRC) | $(BIN_DIR)
	$(COBOL) $(FLAGS) $< -o $@
# --------------------------------------------------
# ALIAS POUR LES CIBLES
# --------------------------------------------------
auth: $(AUTH_BIN)
dashboard:
	$(COBOL) $(FLAGS) \
	modules/dashboard/dashboard-rh.cob \
	-o bin/dashboard

run-dashboard: dashboard
	./bin/dashboard
departement: $(DEPARTEMENT_BIN)
departement-liste: $(DEPARTEMENT_LISTE_BIN)
departement-modifier: $(DEPARTEMENT_MODIFIER_BIN)
departement-supprimer: $(DEPARTEMENT_SUPPRIMER_BIN)

poste: $(POSTE_BIN)
poste-liste: $(POSTE_LISTE_BIN)
poste-modifier: $(POSTE_MODIFIER_BIN)
poste-supprimer: $(POSTE_SUPPRIMER_BIN)

employe: $(EMPLOYE_BIN)
employe-liste: $(EMPLOYE_LISTE_BIN)
employe-modifier: $(EMPLOYE_MODIFIER_BIN)

paie-calculer: $(PAIE_CALCULER_BIN)
paie-lister: $(PAIE_LISTER_BIN)
paie-rapport: $(PAIE_RAPPORT_BIN)
# Alias pour compatibilité avec anciens noms
calculer-paie: $(PAIE_CALCULER_BIN)
lister-paie: $(PAIE_LISTER_BIN)
rapport-paie: $(PAIE_RAPPORT_BIN)
paie: $(PAIE_LISTER_BIN)

presence-ajouter: $(PRESENCE_AJOUTER_BIN)
presence-liste: $(PRESENCE_LISTE_BIN)

conge-demande: $(CONGE_DEMANDE_BIN)
conge-liste: $(CONGE_LISTE_BIN)
conge-valider: $(CONGE_VALIDER_BIN)

rapport-mensuel: $(RAPPORT_MENSUEL_BIN)
export-employes:
	$(COBOL) -x modules/export/export-employes.cob \
	-o bin/export-employes

export-paie:
	$(COBOL) -x modules/export/export-paie.cob \
	-o bin/export-paie

export-conges:
	$(COBOL) -x modules/export/export-conges.cob \
	-o bin/export-conges

user: $(USER_BIN)

user-liste: $(USER_LISTE_BIN)

user-modifier: $(USER_MODIFIER_BIN)

user-supprimer: $(USER_SUPPRIMER_BIN)
menu-rh: $(MENU_RH_BIN)

# --------------------------------------------------
# EXÉCUTION (run)
# --------------------------------------------------
run: menu-rh
	@echo "🚀 Lancement du menu principal..."
	./$(MENU_RH_BIN)

run-auth: auth
	./$(AUTH_BIN)

run-departement-liste: departement-liste
	./$(DEPARTEMENT_LISTE_BIN)

run-departement-modifier: departement-modifier
	./$(DEPARTEMENT_MODIFIER_BIN)

run-departement-supprimer: departement-supprimer
	./$(DEPARTEMENT_SUPPRIMER_BIN)

run-poste-liste: poste-liste
	./$(POSTE_LISTE_BIN)

run-poste-modifier: poste-modifier
	./$(POSTE_MODIFIER_BIN)

run-poste-supprimer: poste-supprimer
	./$(POSTE_SUPPRIMER_BIN)

run-employe-liste: employe-liste
	./$(EMPLOYE_LISTE_BIN)

run-employe-modifier: employe-modifier
	./$(EMPLOYE_MODIFIER_BIN)

run-paie: paie-lister
	./$(PAIE_LISTER_BIN)

run-calculer-paie: paie-calculer
	./$(PAIE_CALCULER_BIN)

run-rapport-paie: paie-rapport
	./$(PAIE_RAPPORT_BIN)

run-presence-ajouter: presence-ajouter
	./$(PRESENCE_AJOUTER_BIN)

run-presence-liste: presence-liste
	./$(PRESENCE_LISTE_BIN)

run-conge-demande: conge-demande
	./$(CONGE_DEMANDE_BIN)

run-conge-liste: conge-liste
	./$(CONGE_LISTE_BIN)

run-conge-valider: conge-valider
	./$(CONGE_VALIDER_BIN)

run-rapport-mensuel: rapport-mensuel
	./$(RAPPORT_MENSUEL_BIN)

# --------------------------------------------------
# EXÉCUTION DE TOUS LES PROGRAMMES (TEST)
# --------------------------------------------------
run-all: run-auth run-departement-liste run-poste-liste run-employe-liste run-paie run-presence-liste run-conge-liste run-rapport-mensuel
	@echo "✅ Tous les programmes ont été exécutés"

# --------------------------------------------------
# VÉRIFICATION DE LA BASE DE DONNÉES
# --------------------------------------------------
check-db:
	@echo "🔍 Vérification de la base de données..."
	@if [ -f $(DB_PATH) ]; then \
		echo "✅ Base de données trouvée : $(DB_PATH)"; \
		sqlite3 $(DB_PATH) ".tables"; \
	else \
		echo "❌ Base de données introuvable : $(DB_PATH)"; \
		echo "   Veuillez exécuter : sqlite3 $(DB_PATH) < schema.sql"; \
		exit 1; \
	fi

# --------------------------------------------------
# NETTOYAGE
# --------------------------------------------------
clean:
	@echo "🧹 Nettoyage des fichiers compilés..."
	rm -f $(BIN_DIR)/*
	rm -rf $(TEMP_DIR)
	@echo "✅ Nettoyage terminé"

clean-all: clean
	@echo "🧹 Suppression du répertoire bin..."
	rm -rf $(BIN_DIR)
	@echo "✅ Nettoyage complet terminé"

# --------------------------------------------------
# RECOMPILATION COMPLÈTE
# --------------------------------------------------
rebuild: clean-all all
	@echo "🔨 Recompilation complète terminée"

# --------------------------------------------------
# AIDE
# --------------------------------------------------
help:
	@echo "========================================="
	@echo "      GESTION RH - MAKEFILE"
	@echo "========================================="
	@echo ""
	@echo "📦 COMPILATION :"
	@echo "  make all              - Compile tout le projet"
	@echo "  make auth             - Compile authentification"
	@echo "  make departement      - Compile ajout département"
	@echo "  make poste            - Compile ajout poste"
	@echo "  make employe          - Compile ajout employé"
	@echo "  make paie-calculer    - Compile calcul de paie"
	@echo "  make menu-rh          - Compile menu principal"
	@echo ""
	@echo "🚀 EXÉCUTION :"
	@echo "  make run              - Lance le menu RH"
	@echo "  make run-calculer-paie - Lance calcul paie"
	@echo "  make run-auth         - Test authentification"
	@echo ""
	@echo "🔧 UTILITAIRES :"
	@echo "  make check-db         - Vérifie la base de données"
	@echo "  make clean            - Nettoie les binaires"
	@echo "  make rebuild          - Recompile tout"
	@echo ""
	@echo "📋 LISTE COMPLÈTE :"
	@echo "  run-departement-liste, run-poste-liste,"
	@echo "  run-employe-liste, run-paie, run-presence-ajouter,"
	@echo "  run-conge-demande, run-rapport-mensuel"
	@echo "========================================="