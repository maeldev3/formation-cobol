#!/bin/bash
#================================================================#
# RUN SCRIPT - Bank Customer Management System                   #
#================================================================#

BIN="bin"
DATA="data"

mkdir -p $DATA

if [ "$1" = "init" ]; then
    echo "Initialisation base de donnees avec donnees exemple..."
    ./$BIN/CUSTINIT
    echo "Termine."
elif [ "$1" = "run" ] || [ -z "$1" ]; then
    if [ ! -f "$BIN/BANKCUST" ]; then
        echo "ERREUR: Programme non compile. Lancer d'abord: ./scripts/build.sh"
        exit 1
    fi
    ./$BIN/BANKCUST
else
    echo "Usage: $0 [init|run]"
    echo "  init  : Initialiser la base avec donnees exemple"
    echo "  run   : Lancer le systeme (defaut)"
fi
