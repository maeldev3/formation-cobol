#!/bin/bash
#================================================================#
# BUILD SCRIPT - Bank Customer Management System                 #
# Compilateur: GnuCOBOL 3.x  (format fixe standard)            #
#================================================================#

COBC="cobc"
SRC="src"
BIN="bin"
DATA="data"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "======================================================="
echo "  COMPILATION - Bank Customer Management System"
echo "======================================================="

mkdir -p "$BIN" "$DATA"

if ! command -v cobc &> /dev/null; then
    echo -e "${RED}ERREUR: GnuCOBOL non installe.${NC}"
    echo "  Ubuntu/Debian : sudo apt-get install gnucobol"
    echo "  Fedora/RHEL   : sudo dnf install gnucobol"
    echo "  macOS         : brew install gnucobol"
    exit 1
fi

echo -e "${GREEN}Compilateur:${NC} $(cobc --version | head -1)"
echo ""

compile_step() {
    local step="$1"
    local desc="$2"
    local flags="$3"
    local src_file="$4"
    local out_file="$5"
    local name="$6"

    echo -e "${YELLOW}[$step] $desc...${NC}"
    if $COBC $flags "$src_file" -o "$out_file" 2>&1; then
        echo -e "${GREEN}  OK: $name compile.${NC}"
    else
        echo -e "${RED}  ERREUR: $name. Compilation arretee.${NC}"
        exit 1
    fi
}

# CUSTVAL : module partagé (.so), pas d'exécutable -> flag -m seul
compile_step "1/3" "Compilation CUSTVAL (module validation)" \
    "-m" \
    "$SRC/CUSTVAL.cbl" \
    "$BIN/CUSTVAL.so" \
    "CUSTVAL"

# CUSTINIT : exécutable standalone
compile_step "2/3" "Compilation CUSTINIT (chargement donnees)" \
    "-x" \
    "$SRC/CUSTINIT.cbl" \
    "$BIN/CUSTINIT" \
    "CUSTINIT"

# BANKCUST : exécutable principal
compile_step "3/3" "Compilation BANKCUST (programme principal)" \
    "-x" \
    "$SRC/BANKCUST.cbl" \
    "$BIN/BANKCUST" \
    "BANKCUST"

echo ""
echo -e "${GREEN}======================================================="
echo "  COMPILATION REUSSIE"
echo -e "=======================================================${NC}"
echo ""
echo "Executables generes dans: ./$BIN/"
echo ""
echo "PROCHAINES ETAPES:"
echo "  1. Initialiser la base : ./scripts/run.sh init"
echo "  2. Lancer le systeme   : ./scripts/run.sh"
echo ""
