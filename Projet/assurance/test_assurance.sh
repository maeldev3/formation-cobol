#!/bin/bash

cd ~/projet/PR-Olivier/cobol/cobol_formation/Projet/assurance

echo "========================================="
echo "TEST COMPLET - SYSTEME ASSURANCE"
echo "========================================="

echo ""
echo ">>> 1. LISTE DES CLIENTS"
./bin/LISTER_CLIENTS

echo ""
echo ">>> 2. RECHERCHE CLIENT C00001"
echo "C00001" | ./bin/RECHERCHE_CLIENT

echo ""
echo ">>> 3. AJOUT CLIENT"
echo -e "C00007\nROUSSEAU\nJulie\n12 Rue Metz 57000 METZ\n0644444444" | ./bin/AJOUT_CLIENT

echo ""
echo ">>> 4. LISTE DES CONTRATS"
./bin/LISTER_CONTRATS

echo ""
echo ">>> 5. CREER CONTRAT"
echo -e "AUTO004\nC00007\nAUTO\n85000\n2025-01-18" | ./bin/CREER_CONTRAT

echo ""
echo ">>> 6. LISTE DES SINISTRES"
./bin/LISTER_SINISTRES

echo ""
echo ">>> 7. DECLARER SINISTRE"
echo -e "AUTO001\n2500" | ./bin/DECLARER_SINISTRE

echo ""
echo ">>> 8. BATCH QUOTIDIEN"
./bin/BATCH_QUOTIDIEN

echo ""
echo ">>> 9. RAPPORT GENERE"
cat data/output/reports/SINISTRES_RAPPORT.rpt

echo ""
echo ">>> 10. VERIFICATION FICHIERS FINAUX"
echo "--- CLIENTS ---"
cat data/input/CLIENTS.DAT
echo ""
echo "--- CONTRATS ---"
cat data/input/CONTRATS.DAT
echo ""
echo "--- SINISTRES ---"
cat data/input/SINISTRES.DAT

echo ""
echo "========================================="
echo "TESTS TERMINES"
echo "========================================="
