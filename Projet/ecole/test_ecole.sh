#!/bin/bash

cd ~/projet/PR-Olivier/cobol/cobol_formation/Projet/ecole

echo "========================================="
echo "TESTS REELS - GESTION ECOLE"
echo "========================================="

echo ""
echo "=== CAS 1: AJOUT ETUDIANT ==="
echo ""
echo "1.1 Ajout nouvel etudiant E00011"
echo -e "E00011\nROBERT\nJulie\n15/03/2012\n3A" | bin/AJOUT_ETUDIANT 2>/dev/null
echo ""
echo "1.2 Liste des etudiants"
bin/LISTER_ETUDIANTS 2>/dev/null | head -12

echo ""
echo "=== CAS 2: AJOUT NOTES ==="
echo ""
echo "2.1 Ajout note Mathematiques pour E00011"
echo -e "E00011\nMAT001\n14.5" | bin/AJOUT_NOTE 2>/dev/null
echo ""
echo "2.2 Ajout note Francais pour E00011"
echo -e "E00011\nFR002\n13.0" | bin/AJOUT_NOTE 2>/dev/null

echo ""
echo "=== CAS 3: BULLETIN ==="
echo ""
echo "3.1 Bulletin de E00011"
echo "E00011" | bin/BULLETIN_ETUDIANT 2>/dev/null
echo ""
echo "3.2 Contenu du bulletin"
cat data/output/reports/BULLETIN.rpt 2>/dev/null

echo ""
echo "=== CAS 4: BATCH ==="
echo ""
echo "4.1 Execution batch quotidien"
bin/BATCH_ECOLE 2>/dev/null
echo ""
echo "4.2 Rapport genere"
cat data/output/reports/RAPPORT_ECOLE.rpt 2>/dev/null | head -15

echo ""
echo "=== RESUME FINAL ==="
echo ""
make status

echo ""
echo "========================================="
echo "TESTS TERMINES"
echo "========================================="
