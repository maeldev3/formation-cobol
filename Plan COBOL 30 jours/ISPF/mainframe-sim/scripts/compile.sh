#!/bin/bash

echo "================================"
echo " COMPILATION COBOL (SIM JCL)"
echo "================================"

cobc -x -free mainframe-sim/cobol/src/LISTER-CONGE.cob \
     -o mainframe-sim/cobol/bin/LISTER-CONGE

echo "COMPILATION TERMINEE"