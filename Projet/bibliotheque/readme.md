cobc -x -free -o bin/AJOUT_ADHERENT src/modules/ADHERENTS/AJOUT_ADHERENT.cob

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