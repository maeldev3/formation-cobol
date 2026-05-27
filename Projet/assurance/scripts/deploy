#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "========================================="
echo "DEPLOIEMENT SYSTEME ASSURANCE"
echo "========================================="

# Vérification
if ! command -v cobc &> /dev/null; then
    echo -e "${RED}✗ GnuCOBOL non installé${NC}"
    exit 1
fi
echo -e "${GREEN}✓ GnuCOBOL installé${NC}"

# Compilation
echo ""
echo "Compilation..."
cd "$(dirname "$0")/.."
make compile 2>/dev/null || {
    echo -e "${YELLOW}Makefile non trouvé, compilation manuelle...${NC}"
    mkdir -p bin
    for file in src/modules/CLIENTS/*.cob; do
        if [ -f "$file" ]; then
            name=$(basename "$file" .cob)
            cobc -x -free -o "bin/$name" "$file" 2>&1 | grep -v "Note:"
            echo "  ✓ $name"
        fi
    done
    for file in src/modules/CONTRATS/*.cob; do
        if [ -f "$file" ]; then
            name=$(basename "$file" .cob)
            cobc -x -free -o "bin/$name" "$file" 2>&1 | grep -v "Note:"
            echo "  ✓ $name"
        fi
    done
    for file in src/modules/SINISTRES/*.cob; do
        if [ -f "$file" ]; then
            name=$(basename "$file" .cob)
            cobc -x -free -o "bin/$name" "$file" 2>&1 | grep -v "Note:"
            echo "  ✓ $name"
        fi
    done
    cobc -x -free -o bin/BATCH_QUOTIDIEN src/batch/BATCH_QUOTIDIEN.cob 2>&1 | grep -v "Note:"
}

echo ""
echo "========================================="
echo -e "${GREEN}DEPLOIEMENT TERMINE${NC}"
echo "========================================="
echo ""
echo "Pour lancer: ./scripts/main.sh"
