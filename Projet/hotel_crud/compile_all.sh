#!/bin/bash

echo "========================================="
echo "COMPILATION UNIQUE - PROJET HOTEL CRUD"
echo "========================================="

cd ~/projet/PR\ OLIVIER/cobol/formation-cobol/Projet/hotel_crud
mkdir -p bin

# Liste de tous les fichiers à compiler
FILES="
src/MENU_PRINCIPAL.cob
src/modules/CLIENTS/CREER_CLIENT.cob
src/modules/CLIENTS/LISTER_CLIENTS.cob
src/modules/CLIENTS/RECHERCHER_CLIENT.cob
src/modules/CLIENTS/MODIFIER_CLIENT.cob
src/modules/CLIENTS/SUPPRIMER_CLIENT.cob
src/modules/CHAMBRES/CREER_CHAMBRE.cob
src/modules/CHAMBRES/LISTER_CHAMBRES.cob
src/modules/CHAMBRES/MODIFIER_CHAMBRE.cob
src/modules/RESERVATIONS/CREER_RESERVATION.cob
src/modules/RESERVATIONS/LISTER_RESERVATIONS.cob
src/modules/RESERVATIONS/ANNULER_RESERVATION.cob
src/modules/RAPPORTS/RAPPORT_OCCUPATION.cob
src/modules/RAPPORTS/RAPPORT_CA.cob
"

COMPTEUR=0
for file in $FILES; do
    if [ -f "$file" ]; then
        nom=$(basename "$file" .cob)
        cobc -x -free -o "bin/$nom" "$file" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "✓ $nom"
            COMPTEUR=$((COMPTEUR + 1))
        else
            echo "✗ $nom (erreur)"
        fi
    else
        echo "⚠ $file n'existe pas"
    fi
done

echo ""
echo "========================================="
echo "$COMPTEUR programmes compilés avec succès"
echo "========================================="
ls -la bin/
