#!/bin/bash
echo "========================================="
echo "COMPILATION PROJET BIBLIOTHEQUE"
echo "========================================="

mkdir -p bin

echo ""
echo "1. Compilation modules ADHERENTS..."
for file in src/modules/ADHERENTS/*.cob; do
    if [ -f "$file" ]; then
        name=$(basename "$file" .cob)
        echo "   → $name"
        cobc -x -free -I src/common/COPYBOOKS -o "bin/$name" "$file" 2>&1 | grep -v "Note:"
    fi
done

echo ""
echo "2. Compilation modules LIVRES..."
for file in src/modules/LIVRES/*.cob; do
    if [ -f "$file" ]; then
        name=$(basename "$file" .cob)
        echo "   → $name"
        cobc -x -free -I src/common/COPYBOOKS -o "bin/$name" "$file" 2>&1 | grep -v "Note:"
    fi
done

echo ""
echo "3. Compilation modules EMPRUNTS..."
for file in src/modules/EMPRUNTS/*.cob; do
    if [ -f "$file" ]; then
        name=$(basename "$file" .cob)
        echo "   → $name"
        cobc -x -free -I src/common/COPYBOOKS -o "bin/$name" "$file" 2>&1 | grep -v "Note:"
    fi
done

echo ""
echo "4. Compilation BATCH..."
for file in src/batch/*.cob; do
    if [ -f "$file" ]; then
        name=$(basename "$file" .cob)
        echo "   → $name"
        cobc -x -free -I src/common/COPYBOOKS -o "bin/$name" "$file" 2>&1 | grep -v "Note:"
    fi
done

echo ""
echo "5. Compilation REPORTS..."
for file in src/reports/*.cob; do
    if [ -f "$file" ]; then
        name=$(basename "$file" .cob)
        echo "   → $name"
        cobc -x -free -I src/common/COPYBOOKS -o "bin/$name" "$file" 2>&1 | grep -v "Note:"
    fi
done

echo ""
echo "========================================="
echo "COMPILATION TERMINEE"
echo "========================================="
ls -la bin/
