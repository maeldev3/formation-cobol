# ==================================================
# Projet : Gestion RH COBOL + SQLite
# Auteur : DEV
# ==================================================

COBOL = cobc
FLAGS = -x

all: auth departement departement-liste departement-modifier departement-supprimer poste poste-liste poste-supprimer poste-modifier employe employe-liste employe-modifier

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
# Supprimer un département
# --------------------------------------------------
departement-supprimer:
	$(COBOL) $(FLAGS) \
	modules/departements/supprimer-departement.cob \
	-o bin/departement-supprimer



# --------------------------------------------------
# Ajouter poste
# --------------------------------------------------
poste:
	$(COBOL) $(FLAGS) \
	modules/postes/ajouter-poste.cob \
	-o bin/poste

poste-liste:
	$(COBOL) $(FLAGS) \
	modules/postes/lister-postes.cob \
	-o bin/poste-liste
poste-supprimer:
	$(COBOL) $(FLAGS) \
	modules/postes/supprimer-poste.cob \
	-o bin/poste-supprimer
poste-modifier:
	$(COBOL) $(FLAGS) \
	modules/postes/modifier-poste.cob \
	-o bin/poste-modifier	



employe:
	$(COBOL) $(FLAGS) \
	modules/employes/ajouter-employe.cob \
	-o bin/employe
employe-liste:
	$(COBOL) $(FLAGS) \
	modules/employes/lister-employes.cob \
	-o bin/employe-liste
employe-modifier:
	$(COBOL) $(FLAGS) \
	modules/employes/modifier-employe.cob \
	-o bin/employe-modifier
# --------------------------------------------------
# Nettoyage
# --------------------------------------------------
clean:
	rm -f bin/*

# --------------------------------------------------
# Recompilation complète
# --------------------------------------------------
rebuild: clean all