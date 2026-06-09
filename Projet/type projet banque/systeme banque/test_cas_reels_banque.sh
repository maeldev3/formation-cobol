#!/bin/bash

cd ~/projet/PR-Olivier/cobol/cobol_formation/Projet/banque

echo "========================================="
echo "TESTS REELS - SYSTEME BANQUE"
echo "========================================="

echo ""
echo "=== CAS 1: Depot sur compte courant ==="
echo ""
echo "1.1 Consultation solde initial CPT001"
echo "CPT001" | bin/CONSULTER_SOLDE 2>/dev/null
echo ""
echo "1.2 Depot de 1000€ sur CPT001"
echo -e "CPT001\n1000" | bin/DEPOT 2>/dev/null
echo ""
echo "1.3 Verification nouveau solde"
echo "CPT001" | bin/CONSULTER_SOLDE 2>/dev/null

echo ""
echo "=== CAS 2: Retrait avec verification solde ==="
echo ""
echo "2.1 Retrait de 500€ sur CPT003 (solde 2500€)"
echo -e "CPT003\n500" | bin/RETRAIT 2>/dev/null
echo ""
echo "2.2 Tentative retrait superieur au solde (3000€)"
echo -e "CPT003\n3000" | bin/RETRAIT 2>/dev/null

echo ""
echo "=== CAS 3: Virement entre comptes ==="
echo ""
echo "3.1 Virement 1000€ de CPT001 vers CPT003"
echo -e "CPT001\nCPT003\n1000" | bin/VIREMENT 2>/dev/null
echo ""
echo "3.2 Verification soldes"
echo "CPT001" | bin/CONSULTER_SOLDE 2>/dev/null
echo "CPT003" | bin/CONSULTER_SOLDE 2>/dev/null

echo ""
echo "=== CAS 4: Batch mensuel ==="
echo ""
echo "4.1 Execution batch"
bin/BATCH_BANQUE 2>/dev/null
echo ""
echo "4.2 Rapport genere"
cat data/output/reports/RAPPORT_BANQUE.rpt 2>/dev/null

echo ""
echo "=== RESUME FINAL ==="
echo ""
echo "Statistiques:"
echo "  Clients: $(wc -l < data/input/CLIENTS.DAT)"
echo "  Comptes: $(wc -l < data/input/COMPTES.DAT)"
echo "  Transactions: $(wc -l < data/input/TRANSACTIONS.DAT)"

echo ""
echo "Historique des transactions CPT001:"
echo "CPT001" | bin/HISTORIQUE_TRANSACTIONS 2>/dev/null | head -10

echo ""
echo "========================================="
echo "TESTS TERMINES"
echo "========================================="
