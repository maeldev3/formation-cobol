#!/bin/bash
cd src
if [ -f CASHMAIN ]; then
    ./CASHMAIN
else
    echo "Erreur: Programme non compile"
fi
cd ..
