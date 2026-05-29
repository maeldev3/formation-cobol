#!/bin/bash
cd ~/projet/PR\ OLIVIER/cobol/formation-cobol/Projet/hotel_crud

echo "=== RAPPORT CHIFFRE D'AFFAIRES ==="
echo ""

echo "=== CA TOTAL ==="
sqlite3 data/input/hotel.db "SELECT SUM(MONTANT) FROM PAIEMENTS;"

echo ""
echo "=== LISTE DES PAIEMENTS ==="
echo "ID        MONTANT  DATE        MODE"
echo "-----------------------------------"
sqlite3 data/input/hotel.db "SELECT ID_PAIEMENT || '   ' || MONTANT || '   ' || DATE_PAIEMENT || '   ' || MODE_PAIEMENT FROM PAIEMENTS;"
