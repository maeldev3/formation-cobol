#!/bin/bash
# Remet les soldes à leurs valeurs initiales et vide l'historique
sqlite3 ../data/epargne.db "DELETE FROM transactions; UPDATE comptes_epargne SET solde = 5000.0 WHERE client_id = 1; UPDATE comptes_epargne SET solde = 3000.0 WHERE client_id = 2;"
echo "Base réinitialisée (soldes: 5000€ et 3000€)."
