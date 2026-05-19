#!/bin/bash

cd ~/projet/PR-Olivier/cobol/cobol_formation/Projet/hopital

echo "========================================="
echo "TESTS REELS - GESTION HOPITAL"
echo "========================================="

echo ""
echo "=== CAS 1: Consultation généraliste ==="
echo ""
echo "1.1 Creation consultation P00001 / M00003"
echo -e "P00001\nM00003\nGrippe avec fievre" | ./bin/AJOUT_CONSULTATION 2>/dev/null
echo "1.2 Generation facture"
echo "C00016" | ./bin/GENERER_FACTURE 2>/dev/null
echo "1.3 Paiement facture"
echo "F00011" | ./bin/PAYER_FACTURE 2>/dev/null

echo ""
echo "=== CAS 2: Consultation pediatrie ==="
echo ""
echo "2.1 Creation consultation P00006 / M00004"
echo -e "P00006\nM00004\nOtite moyenne aigue" | ./bin/AJOUT_CONSULTATION 2>/dev/null
echo "2.2 Generation facture"
echo "C00017" | ./bin/GENERER_FACTURE 2>/dev/null

echo ""
echo "=== CAS 3: Consultation radiologie ==="
echo ""
echo "3.1 Creation consultation P00008 / M00006"
echo -e "P00008\nM00006\nFracture poignet droit" | ./bin/AJOUT_CONSULTATION 2>/dev/null
echo "3.2 Generation facture (sans paiement)"
echo "C00018" | ./bin/GENERER_FACTURE 2>/dev/null

echo ""
echo "=== RESUME FINAL ==="
echo ""
echo "Statistiques:"
echo "  Patients: $(wc -l < data/input/PATIENTS.DAT)"
echo "  Consultations: $(wc -l < data/input/CONSULTATIONS.DAT)"
echo "  Factures: $(wc -l < data/input/FACTURES.DAT)"

echo ""
echo "Factures impayees:"
./bin/LISTER_FACTURES 2>/dev/null | grep " I" | wc -l

echo ""
echo "Execution du batch..."
./bin/BATCH_HOPITAL 2>/dev/null

echo ""
echo "Rapport batch:"
cat data/output/reports/RAPPORT_HOPITAL.rpt 2>/dev/null

echo ""
echo "========================================="
echo "TESTS TERMINES"
echo "========================================="
