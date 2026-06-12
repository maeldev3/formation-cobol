#!/bin/bash

while true
do
clear
echo "======================================"
echo "      MINI MAINFRAME SIMULATOR"
echo "======================================"
echo "1. EDIT (ouvrir COBOL)"
echo "2. COMPILE (JCL step)"
echo "3. RUN (SUBMIT JOB)"
echo "4. LIST FILES"
echo "0. EXIT"
echo "======================================"

read -p "CHOIX : " c

case $c in

1)
    nano mainframe-sim/cobol/src/LISTER-CONGE.cob
;;

2)
    ./mainframe-sim/scripts/compile.sh
    read -p "OK..."
;;

3)
    ./mainframe-sim/scripts/run.sh
    read -p "OK..."
;;

4)
    ls -R mainframe-sim
    read -p "OK..."
;;

0)
    exit
;;

esac

done