#!/bin/bash
#================================================================
# build.sh - Compilation Loan Management System
# GnuCOBOL - Projet #9
#================================================================
set -e

echo "=================================================="
echo "  LOAN MANAGEMENT SYSTEM - Build Script"
echo "=================================================="

mkdir -p data bin

if ! command -v cobc &> /dev/null; then
    echo "ERREUR: GnuCOBOL (cobc) n'est pas installe."
    echo "Installation: sudo apt-get install gnucobol"
    exit 1
fi

echo "GnuCOBOL: $(cobc --version 2>&1 | head -1)"
echo ""

# Verification colonnes
echo "Verification format (72 col. max)..."
for f in src/*.cbl; do
    MAX=$(awk '{ if (length($0) > max) max = length($0) } END { print max }' "$f")
    if [ "$MAX" -gt 72 ]; then
        echo "  WARN: $f depasse 72 col (max=$MAX)"
    else
        echo "  OK: $f (max=$MAX)"
    fi
done

echo ""
echo "Compilation LOAN-MAIN..."
cobc -x -o bin/loan-main src/LOAN-MAIN.cbl && echo "  OK: bin/loan-main"

echo "Compilation LOAN-REPORT..."
cobc -x -o bin/loan-report src/LOAN-REPORT.cbl && echo "  OK: bin/loan-report"

echo ""
echo "=================================================="
echo "  Build OK! Lancer: ./bin/loan-main"
echo "=================================================="
