#!/bin/bash

echo "=== DEPLOIEMENT SYSTEME ASSURANCE ==="

# Vérifier l'installation de GnuCOBOL
if ! command -v cobc &> /dev/null; then
    echo "GnuCOBOL non trouvé. Installation..."
    sudo apt update
    sudo apt install -y gnucobol
fi

# Créer les dossiers nécessaires
cd "$(dirname "$0")/.."
mkdir -p bin data/output/logs data/output/reports

# Compiler
if [ -f compile_all.sh ]; then
    ./compile_all.sh
else
    echo "compile_all.sh non trouvé"
fi

echo "=== DEPLOIEMENT TERMINE ==="
echo "Pour exécuter: ./run_all.sh"
