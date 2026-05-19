#!/bin/bash

echo "========================================="
echo "TESTS REELS - SYSTEME ASSURANCE"
echo "========================================="

cd ~/projet/PR-Olivier/cobol/cobol_formation/Projet/assurance

echo ""
echo "=== CAS 1: Sinistre AUTO - Indemnisation totale ==="
echo ""
echo "1.1 Client C00001:"
echo "C00001" | ./bin/RECHERCHE_CLIENT 2>/dev/null

echo ""
echo "1.2 Sinistre SIN2025001:"
./bin/LISTER_SINISTRES 2>/dev/null | head -5

echo ""
echo "1.3 Indemnisation:"
echo -e "SIN2025001\n1200" | ./bin/INDEMNISER 2>/dev/null

echo ""
echo "=== CAS 2: Nouveau sinistre HABITATION ==="
echo ""
echo "2.1 Ajout client C00007:"
echo -e "C00007\nROUSSEAU\nJulie\n12 Rue Metz\n0644444444" | ./bin/AJOUT_CLIENT 2>/dev/null

echo ""
echo "2.2 Création contrat HABIT010:"
echo -e "HABIT010\nC00007\nHABI\n65000\n2025-05-18" | ./bin/CREER_CONTRAT 2>/dev/null

echo ""
echo "2.3 Déclaration sinistre:"
echo -e "HABIT010\n2500" | ./bin/DECLARER_SINISTRE 2>/dev/null

echo ""
echo "=== CAS 3: Sinistre SANTE refuse ==="
echo ""
echo "3.1 Déclaration sinistre SANTE015:"
echo -e "SANTE015\n15000" | ./bin/DECLARER_SINISTRE 2>/dev/null

echo ""
echo "3.2 Traitement refuse:"
echo -e "SIN2025051802\nR" | ./bin/TRAITER_SINISTRE 2>/dev/null

echo ""
echo "=== RESUME FINAL ==="
echo ""
echo "Nombre de clients: $(wc -l < data/input/CLIENTS.DAT 2>/dev/null || echo 0)"
echo "Nombre de contrats: $(wc -l < data/input/CONTRATS.DAT 2>/dev/null || echo 0)"
echo "Nombre de sinistres: $(wc -l < data/input/SINISTRES.DAT 2>/dev/null || echo 0)"
echo "Nombre de paiements: $(wc -l < data/input/PAIEMENTS.DAT 2>/dev/null || echo 0)"

echo ""
echo "=== LISTE DES PAIEMENTS FINALE ==="
./bin/LISTER_PAIEMENTS 2>/dev/null

echo ""
echo "========================================="
echo "TESTS TERMINES"
echo "========================================="
