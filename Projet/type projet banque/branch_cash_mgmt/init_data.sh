#!/bin/bash
echo "INITIALISATION DES DONNEES"
mkdir -p data reports
echo "2026-06-11|0|2026-06-11 08:00:00|0" > data/cash.dat
echo "Transactions du 2026-06-11" > data/history.dat
echo "INITIALISATION TERMINEE"
echo "CAISSE INITIALISEE A 0 EURO"
ls -la data/
