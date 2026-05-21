#!/bin/bash

echo "========================================="
echo "TESTS REELS - SYSTEME HOTEL CRUD"
echo "========================================="

cd ~/projet/PR\ OLIVIER/cobol/formation-cobol/Projet/hotel_crud

echo ""
echo "=== TEST 1: LISTER LES CLIENTS ==="
./bin/LISTER_CLIENTS

echo ""
echo "=== TEST 2: LISTER LES CHAMBRES ==="
./bin/LISTER_CHAMBRES

echo ""
echo "=== TEST 3: LISTER LES RESERVATIONS ==="
./bin/LISTER_RESERVATIONS

echo ""
echo "=== TEST 4: RAPPORT OCCUPATION ==="
./bin/RAPPORT_OCCUPATION

echo ""
echo "=== TEST 5: RAPPORT CA ==="
./bin/RAPPORT_CA

echo ""
echo "=== TEST 6: CREER UN NOUVEAU CLIENT ==="
echo -e "C00010\nBERNARD\nClaude\nclaude@email.com\n0666666666\n10 Rue Test\nParis\n75000" | ./bin/CREER_CLIENT

echo ""
echo "=== TEST 7: VERIFICATION NOUVEAU CLIENT ==="
./bin/LISTER_CLIENTS

echo ""
echo "========================================="
echo "TESTS TERMINES"
echo "========================================="
