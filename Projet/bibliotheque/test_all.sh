#!/bin/bash

echo "========================================="
echo "TEST COMPLET - BIBLIOTHEQUE"
echo "========================================="

cd ~/projet/PR-Olivier/cobol/cobol_formation/Projet/bibliotheque

echo ""
echo ">>> 1. LISTE ADHERENTS (avant ajout)"
./bin/LISTER_ADHERENTS

echo ""
echo ">>> 2. AJOUT ADHERENT A00006"
echo -e "A00006\nBERNARD\nClaude\n8 Rue Nancy 54000 NANCY\n2025-01-18\n45" | ./bin/AJOUT_ADHERENT

echo ""
echo ">>> 3. AJOUT ADHERENT A00007"
echo -e "A00007\nROUSSEAU\nJulie\n12 Rue Metz 57000 METZ\n2025-01-18\n28" | ./bin/AJOUT_ADHERENT

echo ""
echo ">>> 4. TEST AJOUT ID EXISTANT (doit échouer)"
echo -e "A00001\nTEST\nERREUR\nADRESSE\n2025-01-18\n30" | ./bin/AJOUT_ADHERENT

echo ""
echo ">>> 5. TEST AJOUT MINEUR (doit échouer)"
echo -e "A00099\nMINEUR\nJean\nRue Test\n2025-01-18\n16" | ./bin/AJOUT_ADHERENT

echo ""
echo ">>> 6. RECHERCHE ADHERENT A00001"
echo "A00001" | ./bin/RECHERCHE_ADHERENT

echo ""
echo ">>> 7. RECHERCHE ADHERENT INEXISTANT"
echo "A00999" | ./bin/RECHERCHE_ADHERENT

echo ""
echo ">>> 8. LISTE LIVRES (avant ajout)"
./bin/LISTER_LIVRES

echo ""
echo ">>> 9. AJOUT LIVRE"
echo -e "978-8-901234567\nLa Peste\nCamus\nPhilosophie\n2" | ./bin/AJOUT_LIVRE

echo ""
echo ">>> 10. AJOUT AUTRE LIVRE"
echo -e "978-9-012345678\nBel-Ami\nMaupassant\nClassique\n3" | ./bin/AJOUT_LIVRE

echo ""
echo ">>> 11. RECHERCHE LIVRE 978-2-123456789"
echo "978-2-123456789" | ./bin/RECHERCHE_LIVRE

echo ""
echo ">>> 12. RECHERCHE LIVRE INEXISTANT"
echo "978-0-000000000" | ./bin/RECHERCHE_LIVRE

echo ""
echo ">>> 13. EMPRUNTS EN COURS (avant emprunts)"
./bin/EMPRUNTS_EN_COURS

echo ""
echo ">>> 14. EMPRUNTER LIVRE (A00001 -> 1984)"
echo -e "A00001\n978-0-123456789" | ./bin/EMPRUNTER

echo ""
echo ">>> 15. EMPRUNTER LIVRE (A00003 -> Le Rouge et le Noir)"
echo -e "A00003\n978-3-456789012" | ./bin/EMPRUNTER

echo ""
echo ">>> 16. TEST EMPRUNT ADHERENT INEXISTANT"
echo -e "A00999\n978-2-123456789" | ./bin/EMPRUNTER

echo ""
echo ">>> 17. RETOUR LIVRE E00001"
echo "E00001" | ./bin/RETOUR

echo ""
echo ">>> 18. RETOUR LIVRE E00002"
echo "E00002" | ./bin/RETOUR

echo ""
echo ">>> 19. RETOUR EMPRUNT INEXISTANT"
echo "E00999" | ./bin/RETOUR

echo ""
echo ">>> 20. EMPRUNTS EN COURS (apres retours)"
./bin/EMPRUNTS_EN_COURS

echo ""
echo ">>> 21. BATCH AMENDES"
./bin/BATCH_AMENDES

echo ""
echo ">>> 22. RAPPORT GENERÉ"
cat data/output/reports/AMENDES.rpt

echo ""
echo ">>> 23. VERIFICATION FICHIER ADHERENTS FINAL"
cat data/input/ADHERENTS.DAT

echo ""
echo ">>> 24. VERIFICATION FICHIER LIVRES FINAL"
cat data/input/LIVRES.DAT

echo ""
echo "========================================="
echo "TESTS TERMINES"
echo "========================================="
