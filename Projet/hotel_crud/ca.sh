#!/bin/bash
cd ~/projet/PR\ OLIVIER/cobol/formation-cobol/Projet/hotel_crud
echo "=== CA TOTAL ==="
sqlite3 data/input/hotel.db "SELECT SUM(MONTANT) FROM PAIEMENTS;"
echo ""
echo "=== LISTE DES PAIEMENTS ==="
sqlite3 data/input/hotel.db "SELECT ID_PAIEMENT || ' - ' || MONTANT || ' euros' FROM PAIEMENTS;"
