#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="$PROJECT_DIR/bin"

echo "=== TESTS D'INTEGRATION ==="
echo ""

# Test 1: Vérifier présence binaires
echo "1. Vérification des binaires"
for bin in LISTER_CLIENTS LISTER_CONTRATS LISTER_SINISTRES; do
    if [ -f "$BIN_DIR/$bin" ]; then
        echo -e "${GREEN}✓ $bin présent${NC}"
    else
        echo -e "${RED}✗ $bin manquant${NC}"
    fi
done

echo ""
echo "=== TESTS TERMINES ==="
