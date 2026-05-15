#!/bin/bash

echo "=== COMPILATION DU PROJET COBOL ==="

# Nettoyage
rm -f bin/*

# Compilation du sous-programme
echo "Compilation de VALIDATION..."
cobc -m src/VALIDATION.cob -o bin/VALIDATION.so

# Compilation du programme principal
echo "Compilation de PRINCIPAL..."
cobc -x src/PRINCIPAL.cob -I copybooks/ -o bin/PRINCIPAL

# Copie de la bibliothèque
cp bin/VALIDATION.so .

echo "=== COMPILATION TERMINEE ==="
echo "Pour exécuter: ./bin/PRINCIPAL"
