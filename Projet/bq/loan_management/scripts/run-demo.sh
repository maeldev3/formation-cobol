#!/bin/bash
#================================================================
# run-demo.sh - Demo automatique du Loan Management System
#================================================================

echo "=================================================="
echo "  DEMO - Loan Management System"
echo "=================================================="

mkdir -p data bin

# Compilation
./scripts/build.sh 2>/dev/null || {
    echo "Build requis d'abord. Tentative..."
    mkdir -p bin
    cobc -x -free -o bin/loan-main src/LOAN-MAIN.cbl 2>&1
}

echo ""
echo "Demarrage du systeme..."
echo ""
echo "Navigation suggere pour la demo:"
echo "  1 = Nouvelle demande -> saisir client, montant, taux, duree"
echo "  7 = Simulateur rapide (sans sauvegarder)"
echo "  2 = Valider une demande existante"
echo "  4 = Tableau d'amortissement"
echo "  5 = Liste de tous les prets"
echo "  6 = Statistiques"
echo "  0 = Quitter"
echo ""
echo "Appuyer sur ENTREE pour lancer..."
read

./bin/loan-main
