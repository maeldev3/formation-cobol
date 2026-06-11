#!/bin/bash
echo "======================================"
echo "BRANCH CASH MANAGEMENT SYSTEM"
echo "======================================"
cd src
if [ -f CASHMAIN ]; then
    ./CASHMAIN
else
    echo "Erreur: Programme non compile"
    echo "Lancez d'abord ./compile.sh"
fi
cd ..
