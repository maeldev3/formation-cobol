#!/bin/bash

mkdir -p bin

echo "================================="
echo "COMPILATION ATM BANKING SYSTEM"
echo "================================="

cobc -x -free \
-o bin/MENU_PRINCIPAL \
src/MENU_PRINCIPAL.cob

cobc -x -free \
-o bin/CREER_COMPTE \
src/modules/ADMIN/CREER_COMPTE.cob

cobc -x -free \
-o bin/CONSULTER_SOLDE \
src/modules/ACCOUNT/CONSULTER_SOLDE.cob

cobc -x -free -o bin/MENU_PRINCIPAL src/MENU_PRINCIPAL.cob
cobc -x -free -o bin/CREER_COMPTE src/modules/ADMIN/CREER_COMPTE.cob
cobc -x -free -o bin/CONSULTER_SOLDE src/modules/ACCOUNT/CONSULTER_SOLDE.cob
cobc -x -free -o bin/DEPOT src/modules/TRANSACTIONS/DEPOT.cob
cobc -x -free -o bin/RETRAIT src/modules/TRANSACTIONS/RETRAIT.cob
cobc -x -free -o bin/MINI_RELEVE src/modules/ACCOUNT/MINI_RELEVE.cob

	@echo "Compilation terminée"

echo " "
echo "Compilation terminée"
ls -l bin
