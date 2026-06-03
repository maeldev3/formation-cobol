# ==================================================
# Projet : Gestion RH COBOL + SQLite
# Auteur : DEV
# ==================================================

COBOL = cobc
FLAGS = -x

all: auth departement departement-liste \
     poste poste-liste poste-modifier poste-supprimer \
     employe employe-liste employe-modifier \
     paie \
     presence-ajouter presence-liste \
     conge-demande conge-liste conge-valider \
     rapport-mensuel \
     menu-rh \
	 calculer-paie lister-paie rapport-paie

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

# --------------------------------------------------
# Ajouter employé
# --------------------------------------------------
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
# Paie
# --------------------------------------------------
paie:
	$(COBOL) $(FLAGS) \
	modules/paie/lister-paie.cob \
	-o bin/paie

# --------------------------------------------------
# Présence
# --------------------------------------------------
presence-ajouter:
	$(COBOL) $(FLAGS) modules/presence/ajouter-presence.cob -o bin/presence-ajouter

presence-liste:
	$(COBOL) $(FLAGS) modules/presence/lister-presence.cob -o bin/presence-liste

# --------------------------------------------------
# Congés
# --------------------------------------------------
conge-demande:
	$(COBOL) $(FLAGS) \
	modules/conges/demande-conge.cob \
	-o bin/conge-demande

conge-liste:
	$(COBOL) $(FLAGS) \
	modules/conges/lister-conge.cob \
	-o bin/conge-liste

conge-valider:
	$(COBOL) $(FLAGS) \
	modules/conges/valider-conge.cob \
	-o bin/conge-valider

# --------------------------------------------------
# Rapport mensuel
# --------------------------------------------------
rapport-mensuel:
	$(COBOL) $(FLAGS) \
	modules/rapport/rapport-mensuel.cob \
	-o bin/rapport-mensuel
# calculer-paie:
# 	$(COBOL) -x \
# 	modules/paie/calculer-paie.cob \
# 	-o bin/calculer-paie

# lister-paie:
# 	$(COBOL) -x \
# 	modules/paie/lister-paie.cob \
# 	-o bin/lister-paie

# rapport-paie:
# 	$(COBOL) -x \
# 	modules/paie/rapport-paie.cob \
# 	-o bin/rapport-paie
# --------------------------------------------------
# Menu principal RH
# --------------------------------------------------
menu-rh:
	$(COBOL) $(FLAGS) \
	modules/menu/menu-rh.cob \
	-o bin/menu-rh

# --------------------------------------------------
# Exécution des programmes (commandes run)
# --------------------------------------------------
run: menu-rh
	./bin/menu-rh

run-auth: auth
	./bin/login

run-departement-liste: departement-liste
	./bin/departement-liste

run-departement-modifier: departement-modifier
	./bin/departement-modifier

run-departement-supprimer: departement-supprimer
	./bin/departement-supprimer

run-poste-liste: poste-liste
	./bin/poste-liste

run-poste-modifier: poste-modifier
	./bin/poste-modifier

run-poste-supprimer: poste-supprimer
	./bin/poste-supprimer

run-employe-liste: employe-liste
	./bin/employe-liste

run-employe-modifier: employe-modifier
	./bin/employe-modifier

run-paie: paie
	./bin/paie

run-presence-ajouter: presence-ajouter
	./bin/presence-ajouter

run-presence-liste: presence-liste
	./bin/presence-liste

run-conge-demande: conge-demande
	./bin/conge-demande

run-conge-liste: conge-liste
	./bin/conge-liste

run-conge-valider: conge-valider
	./bin/conge-valider

run-rapport-mensuel: rapport-mensuel
	./bin/rapport-mensuel

calculer-paie:
	$(COBOL) -x \
	modules/paie/calculer-paie.cob \
	-o bin/calculer-paie

lister-paie:
	$(COBOL) -x \
	modules/paie/lister-paie.cob \
	-o bin/lister-paie

rapport-paie:
	$(COBOL) -x \
	modules/paie/rapport-paie.cob \
	-o bin/rapport-paie
# --------------------------------------------------
# Nettoyage
# --------------------------------------------------
clean:
	rm -f bin/*

# --------------------------------------------------
# Recompilation complète
# --------------------------------------------------
rebuild: clean all