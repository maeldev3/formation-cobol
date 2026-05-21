cobc -x -free -o bin/AJOUT_ADHERENT src/modules/ADHERENTS/AJOUT_ADHERENT.cob
cobc -x -free -o bin/SUPPR_ADHERENT src/modules/ADHERENTS/SUPPR_ADHERENT.cob
cobc -x -free -o bin/AJOUT_ADHERENT src/modules/ADHERENTS/AJOUT_ADHERENT.cob


# ===========================================
# PROGRAMMES LIVRES
# ===========================================

# Ajouter un livre
cobc -x -free -o bin/AJOUT_LIVRE src/modules/LIVRES/AJOUT_LIVRE.cob

# Supprimer un livre
cobc -x -free -o bin/SUPPR_LIVRE src/modules/LIVRES/SUPPR_LIVRE.cob

# Modifier un livre
cobc -x -free -o bin/MODIF_LIVRE src/modules/LIVRES/MODIF_LIVRE.cob

# Lister les livres
cobc -x -free -o bin/LISTE_LIVRE src/modules/LIVRES/LISTE_LIVRE.cob

# Rechercher un livre
cobc -x -free -o bin/RECHERCHE_LIVRE src/modules/LIVRES/RECHERCHE_LIVRE.cob

# ===========================================
# PROGRAMMES EMPRUNTS
# ===========================================

# Ajouter un emprunt
cobc -x -free -o bin/AJOUT_EMPRUNT src/modules/EMPRUNTS/AJOUT_EMPRUNT.cob

# Retourner un livre
cobc -x -free -o bin/RETOUR_EMPRUNT src/modules/EMPRUNTS/RETOUR_EMPRUNT.cob

# Lister les emprunts
cobc -x -free -o bin/LISTE_EMPRUNT src/modules/EMPRUNTS/LISTE_EMPRUNT.cob



Ajotuer
echo -e "A00006\nBERNARD\nClaude\n8 Rue Nancy 54000 NANCY\n2025-01-18\n45" | ./bin/AJOUT_ADHERENT
echo -e "A00007\nROUSSEAU\nJulie\n12 Rue Metz 57000 METZ\n2025-01-18\n28" | ./bin/AJOUT_ADHERENT
Ajouter un adhérent mineur (doit échouer)
echo -e "A00099\nMINEUR\nJean\nRue Test\n2025-01-18\n16" | ./bin/AJOUT_ADHERENT
Recherche
echo "A00006" | ./bin/RECHERCHE_ADHERENT

Ajotuer livre 
echo -e "978-8-901234567\nLa Peste\nCamus\nPhilosophie\n2" | ./bin/AJOUT_LIVRE
echo -e "978-9-012345678\nBel-Ami\nMaupassant\nClassique\n3" | ./bin/AJOUT_LIVRE
Recherche livre 
echo "978-2-123456789" | ./bin/RECHERCHE_LIVRE