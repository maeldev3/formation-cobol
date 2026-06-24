#!/bin/bash
echo "COMPILATION..."
cd src
rm -f CASHMAIN
cobc -x CASHMAIN.cbl -o CASHMAIN
if [ -f CASHMAIN ]; then
    echo "SUCCES"
    ls -la CASHMAIN
else
    echo "ECHEC"
fi
cd ..
