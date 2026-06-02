# ==================================================
# Projet : Gestion RH COBOL + SQLite
# Auteur : DEV
# ==================================================

COBOL = cobc
FLAGS = -x

all: auth departement departement-liste departement-modifier

# --------------------------------------------------
# Authentification
# --------------------------------------------------
auth:
	$(COBOL) $(FLAGS) \
	modules/auth/authentifier.cob \
	-o bin/login

# --------------------------------------------------
# Ajouter un département
# --------------------------------------------------
departement:
	$(COBOL) $(FLAGS) \
	modules/departements/ajouter-departement.cob \
	-o bin/departement

# --------------------------------------------------
# Lister les départements
# --------------------------------------------------
departement-liste:
	$(COBOL) $(FLAGS) \
	modules/departements/lister-departements.cob \
	-o bin/departement-liste
departement-modifier:
	$(COBOL) $(FLAGS) \
	modules/departements/modifier-departement.cob \
	-o bin/departement-modifier


# --------------------------------------------------
# Nettoyage
# --------------------------------------------------
clean:
	rm -f bin/*

# --------------------------------------------------
# Recompilation complète
# --------------------------------------------------
rebuild: clean all