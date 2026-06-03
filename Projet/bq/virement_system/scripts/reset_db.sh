#!/bin/bash
DB_PATH="../data/banque.db"
sqlite3 $DB_PATH "DELETE FROM transactions; UPDATE comptes SET solde = 5000.0 WHERE client_id = 1; UPDATE comptes SET solde = 3000.0 WHERE client_id = 2;"
echo "Base réinitialisée (soldes: 5000€ et 3000€)."
