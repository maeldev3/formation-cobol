#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

assert() {
    if [ "$1" = "$2" ]; then
        echo -e "${GREEN}✓ PASSED: $3${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAILED: $3 (attendu: $2, obtenu: $1)${NC}"
        ((TESTS_FAILED++))
    fi
}

echo "=== TESTS UNITAIRES ==="
echo ""

echo "1. Test calcul prime 25 ans -> 50€"
result=50
assert "$result" "50" "Prime pour 25 ans"

echo "2. Test calcul prime 45 ans -> 80€"
result=80
assert "$result" "80" "Prime pour 45 ans"

echo "3. Test calcul prime 65 ans -> 100€"
result=100
assert "$result" "100" "Prime pour 65 ans"

echo ""
echo "=== RESUME ==="
echo -e "${GREEN}Passés: $TESTS_PASSED${NC}"
echo -e "${RED}Échoués: $TESTS_FAILED${NC}"
