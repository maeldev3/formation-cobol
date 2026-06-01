#!/bin/bash
sqlite3 ../data/atm.db "DELETE FROM transactions; UPDATE comptes SET solde = 500.0 WHERE carte_id = 1; UPDATE cartes SET bloquee = 0 WHERE carte_id = 1;"
echo "Base réinitialisée (solde 500€, carte débloquée, historique vidé)."
