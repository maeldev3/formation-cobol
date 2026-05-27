#!/bin/bash

DB_PATH="data/sqlite/banque.db"

echo "========================================="
echo "TEST DES MODULES"
echo "========================================="

# Test crédit
echo ""
echo "1. Test création crédit..."
sqlite3 "$DB_PATH" <<EOF
SELECT demander_credit('CPT001', 'CONSOMMATION', 10000, 36, 'Aucune');
