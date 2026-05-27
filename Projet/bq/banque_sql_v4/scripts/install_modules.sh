#!/bin/bash

# Installation de tous les modules SQL
DB_PATH="data/sqlite/banque.db"

echo "========================================="
echo "Installation des modules SQL"
echo "========================================="

# Vérifier si la base existe
if [ ! -f "$DB_PATH" ]; then
    echo "Base de données non trouvée. Initialisation..."
    sqlite3 "$DB_PATH" < scripts/init_db.sql
fi

# Installer les modules
for module in CARTES CREDITS AGENCES EMPLOYES ALERTES RAPPORTS; do
    echo "Installation module $module..."
    sqlite3 "$DB_PATH" < "src/modules/${module}.sql" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "  ✓ Module $module installé"
    else
        echo "  ✗ Erreur module $module (peut être déjà installé)"
    fi
done

echo ""
echo "✅ Installation terminée"
