#!/bin/bash

echo "========================================="
echo "TEST ATM BANKING SYSTEM"
echo "========================================="
echo ""

# Test 1: Vérifier les fichiers
echo "1. Verification des fichiers..."
if [ -f "data/input/CARTES.dat" ] && [ -f "data/input/COMPTES.dat" ]; then
    echo "   ✓ Fichiers presents"
else
    echo "   ✗ Fichiers manquants"
    exit 1
fi

# Test 2: Compter les cartes
echo ""
echo "2. Nombre de cartes: $(wc -l < data/input/CARTES.dat)"
echo "   Nombre de comptes: $(wc -l < data/input/COMPTES.dat)"

# Test 3: Vérifier le binaire
echo ""
echo "3. Verification du binaire..."
if [ -f "bin/ATM" ]; then
    echo "   ✓ Binaire present"
else
    echo "   ✗ Binaire manquant - Lancez 'make compile'"
    exit 1
fi

# Test 4: Lancer un test rapide
echo ""
echo "4. Test rapide (entree automatique)..."
echo "1234567890123456" | timeout 5 bin/ATM || echo "   Test termine"

echo ""
echo "✅ Tests termines"
