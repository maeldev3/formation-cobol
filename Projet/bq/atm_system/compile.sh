#!/bin/bash
cd "$(dirname "$0")"
mkdir -p bin
echo "Compilation des modules ATM..."

for prog in AUTHENTIFIER SOLDE RETRAIT DEPOT HISTORIQUE LOGOUT; do
    echo -n "Compilation de $prog... "
    cobc -x -free -I src/ -o bin/$prog src/$prog.cob 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓"
    else
        echo "✗ (erreur)"
    fi
done

echo "Compilation terminée. Exécutables dans bin/"
ls -la bin/
