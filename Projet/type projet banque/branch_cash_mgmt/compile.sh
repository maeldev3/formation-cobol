#!/bin/bash
echo "======================================"
echo "COMPILATION DU BRANCH CASH SYSTEM"
echo "======================================"
cd src
cobc -x CASHMAIN.cbl -o CASHMAIN
if [ -f CASHMAIN ]; then
    echo "COMPILATION REUSSIE"
    ls -la CASHMAIN
else
    echo "ERREUR DE COMPILATION"
fi
cd ..
