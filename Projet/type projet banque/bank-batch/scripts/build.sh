#!/bin/bash
#================================================================
# build.sh - Compilation Bank Batch Processing System
# GnuCOBOL - Projet #10
#================================================================

set -e

# Se placer à la racine du projet
cd "$(dirname "$0")/.."

echo "=================================================="
echo "  BANK BATCH PROCESSING SYSTEM - Build"
echo "=================================================="

mkdir -p data bin logs

if ! command -v cobc &> /dev/null; then
    echo "ERREUR: GnuCOBOL non installe."
    echo "  sudo apt-get install gnucobol"
    exit 1
fi
echo "GnuCOBOL: $(cobc --version 2>&1 | head -1)"
echo ""

# Verification colonnes
echo "Verification colonnes (72 max)..."
OK=true
for f in src/*.cbl; do
    MAX=$(awk '{ if (length($0) > max) max = length($0) } END { print max }' "$f")
    if [ "$MAX" -gt 72 ]; then
        echo "  WARN: $f => max $MAX colonnes"
        OK=false
    else
        echo "  OK  : $f ($MAX col)"
    fi
done
echo ""

# Compilation
echo "Compilation..."

cobc -x -o bin/batch-init    src/BATCH-INIT.cbl
echo "  OK: bin/batch-init"

cobc -x -o bin/batch-main    src/BATCH-MAIN.cbl
echo "  OK: bin/batch-main"

cobc -x -o bin/batch-history src/BATCH-HISTORY.cbl
echo "  OK: bin/batch-history"

echo ""
echo "=================================================="
echo "  Build termine!"
echo ""
echo "  DEMARRAGE RAPIDE:"
echo "  1. Initialiser les donnees  : ./bin/batch-init"
echo "  2. Lancer le batch          : ./bin/batch-main"
echo "  3. Voir historique          : ./bin/batch-history"
echo "=================================================="
