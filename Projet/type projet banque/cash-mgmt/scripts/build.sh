#!/bin/bash
#============================================================
# build.sh - Compilation Branch Cash Management System
# GnuCOBOL + SQLite (liaison statique pont C)
#============================================================
set -e
cd "$(dirname "$0")/.."

echo "=================================================="
echo "  BRANCH CASH MANAGEMENT SYSTEM - Build"
echo "=================================================="

mkdir -p db bin bridge

if ! command -v cobc &>/dev/null; then
    echo "ERREUR: GnuCOBOL non installe."
    echo "  sudo apt-get install gnucobol"
    exit 1
fi
if [ ! -f /usr/include/sqlite3.h ]; then
    echo "ERREUR: libsqlite3-dev non installe."
    echo "  sudo apt-get install libsqlite3-dev sqlite3"
    exit 1
fi

echo "GnuCOBOL : $(cobc --version 2>&1 | head -1)"
echo "SQLite   : $(sqlite3 --version 2>&1 | head -1)"
echo ""

echo "[1/2] Compilation CASH-INIT (COBOL + C bridge + SQLite)..."
cobc -x -o bin/cash-init \
    -I src \
    src/CASH-INIT.cbl \
    bridge/db_bridge.c \
    -lsqlite3 2>/dev/null
echo "  OK: bin/cash-init"

echo "[2/2] Compilation CASH-MAIN (COBOL + C bridge + SQLite)..."
cobc -x -o bin/cash-main \
    -I src \
    src/CASH-MAIN.cbl \
    bridge/db_bridge.c \
    -lsqlite3 2>/dev/null
echo "  OK: bin/cash-main"

echo ""
echo "=================================================="
echo "  Build termine!"
echo ""
echo "  DEMARRAGE:"
echo "  1. ./bin/cash-init        (premiere fois)"
echo "  2. ./scripts/run.sh       (mode interactif)"
echo "  3. ./scripts/run-demo.sh  (demo automatique)"
echo "=================================================="
