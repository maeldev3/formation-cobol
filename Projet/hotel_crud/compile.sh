#!/bin/bash

echo "========================================="
echo "COMPILATION DU PROJET HOTEL CRUD"
echo "========================================="

cd ~/projet/PR\ OLIVIER/cobol/formation-cobol/Projet/hotel_crud
mkdir -p bin

echo "Compilation des modules..."

# CLIENTS
cobc -x -free -o bin/CREER_CLIENT src/modules/CLIENTS/CREER_CLIENT.cob 2>/dev/null && echo "✓ CREER_CLIENT" || echo "✗ CREER_CLIENT"
cobc -x -free -o bin/LISTER_CLIENTS src/modules/CLIENTS/LISTER_CLIENTS.cob 2>/dev/null && echo "✓ LISTER_CLIENTS" || echo "✗ LISTER_CLIENTS"
cobc -x -free -o bin/RECHERCHER_CLIENT src/modules/CLIENTS/RECHERCHER_CLIENT.cob 2>/dev/null && echo "✓ RECHERCHER_CLIENT" || echo "✗ RECHERCHER_CLIENT"
cobc -x -free -o bin/MODIFIER_CLIENT src/modules/CLIENTS/MODIFIER_CLIENT.cob 2>/dev/null && echo "✓ MODIFIER_CLIENT" || echo "✗ MODIFIER_CLIENT"
cobc -x -free -o bin/SUPPRIMER_CLIENT src/modules/CLIENTS/SUPPRIMER_CLIENT.cob 2>/dev/null && echo "✓ SUPPRIMER_CLIENT" || echo "✗ SUPPRIMER_CLIENT"

# CHAMBRES
cobc -x -free -o bin/CREER_CHAMBRE src/modules/CHAMBRES/CREER_CHAMBRE.cob 2>/dev/null && echo "✓ CREER_CHAMBRE" || echo "✗ CREER_CHAMBRE"
cobc -x -free -o bin/LISTER_CHAMBRES src/modules/CHAMBRES/LISTER_CHAMBRES.cob 2>/dev/null && echo "✓ LISTER_CHAMBRES" || echo "✗ LISTER_CHAMBRES"
cobc -x -free -o bin/MODIFIER_CHAMBRE src/modules/CHAMBRES/MODIFIER_CHAMBRE.cob 2>/dev/null && echo "✓ MODIFIER_CHAMBRE" || echo "✗ MODIFIER_CHAMBRE"

# RESERVATIONS
cobc -x -free -o bin/CREER_RESERVATION src/modules/RESERVATIONS/CREER_RESERVATION.cob 2>/dev/null && echo "✓ CREER_RESERVATION" || echo "✗ CREER_RESERVATION"
cobc -x -free -o bin/LISTER_RESERVATIONS src/modules/RESERVATIONS/LISTER_RESERVATIONS.cob 2>/dev/null && echo "✓ LISTER_RESERVATIONS" || echo "✗ LISTER_RESERVATIONS"
cobc -x -free -o bin/ANNULER_RESERVATION src/modules/RESERVATIONS/ANNULER_RESERVATION.cob 2>/dev/null && echo "✓ ANNULER_RESERVATION" || echo "✗ ANNULER_RESERVATION"

# RAPPORTS
cobc -x -free -o bin/RAPPORT_OCCUPATION src/modules/RAPPORTS/RAPPORT_OCCUPATION.cob 2>/dev/null && echo "✓ RAPPORT_OCCUPATION" || echo "✗ RAPPORT_OCCUPATION"
cobc -x -free -o bin/RAPPORT_CA src/modules/RAPPORTS/RAPPORT_CA.cob 2>/dev/null && echo "✓ RAPPORT_CA" || echo "✗ RAPPORT_CA"

# MENU
cobc -x -free -o bin/MENU_PRINCIPAL src/MENU_PRINCIPAL.cob 2>/dev/null && echo "✓ MENU_PRINCIPAL" || echo "✗ MENU_PRINCIPAL"

echo ""
echo "========================================="
echo "COMPILATION TERMINEE"
echo "========================================="
ls -la bin/
