#!/bin/bash
#================================================================
# run-demo.sh - Demo automatique complete
#================================================================

# Se placer à la racine du projet
cd "$(dirname "$0")/.."

echo "=================================================="
echo "  DEMO - Bank Batch Processing System"
echo "=================================================="

mkdir -p data bin logs

# Build si necessaire
if [ ! -f bin/batch-main ]; then
    echo "Build en cours..."
    ./scripts/build.sh
fi

echo ""
echo "ETAPE 1 : Initialisation des 20 comptes de test..."
./bin/batch-init
echo ""

echo "ETAPE 2 : Liste des comptes avant batch..."
printf "8\n1\n0\n" | ./bin/batch-main
echo ""

echo "ETAPE 3 : Lancement batch COMPLET..."
printf "1\nO\n0\n" | ./bin/batch-main
echo ""

echo "ETAPE 4 : Historique des transactions..."
printf "1\n0\n" | ./bin/batch-history
echo ""

echo "ETAPE 5 : Affichage rapport..."
cat logs/BATCH_REPORT.txt 2>/dev/null || echo "  (rapport non trouve)"

echo ""
echo "=================================================="
echo "  Demo terminee."
echo "  Pour mode interactif: ./bin/batch-main"
echo "=================================================="
