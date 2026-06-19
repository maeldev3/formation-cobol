#!/bin/bash
###############################################################################
# test_local.sh
# Permet de tester HELLOBANK.cbl SANS mainframe, sur un PC/Linux/Mac,
# avec le compilateur libre GnuCOBOL (https://gnucobol.sourceforge.io/).
#
# ATTENTION : ce script crée une COPIE temporaire du programme avec
# ORGANIZATION IS LINE SEQUENTIAL (format texte avec retours à la ligne)
# au lieu de ORGANIZATION IS SEQUENTIAL (format mainframe FB/QSAM).
# C'est uniquement pour pouvoir lire des fichiers .txt classiques en local.
# Le fichier .cbl original (mainframe) N'EST PAS modifié.
#
# INSTALLATION DE GNUCOBOL :
#   Ubuntu/Debian : sudo apt-get install gnucobol3   (ou gnucobol4)
#   Mac (brew)    : brew install gnu-cobol
#   Windows       : via WSL (Ubuntu) ou MinGW
#
# UTILISATION :
#   chmod +x test_local.sh
#   ./test_local.sh
###############################################################################
set -e

cd "$(dirname "$0")"

echo ">> Verification de GnuCOBOL..."
if ! command -v cobc &> /dev/null; then
    echo "ERREUR : 'cobc' introuvable. Installez GnuCOBOL d'abord :"
    echo "  Ubuntu/Debian : sudo apt-get install gnucobol3"
    exit 1
fi

WORKDIR=$(mktemp -d)
echo ">> Repertoire de travail temporaire : $WORKDIR"

cp src/HELLOBANK.cbl "$WORKDIR/HELLOBANK_TEST.cbl"
cp data/CLIENTS.txt "$WORKDIR/CLIENTS.txt"
cp data/TRANS.txt   "$WORKDIR/TRANS.txt"

# Adaptation UNIQUEMENT pour le test local (texte / LINE SEQUENTIAL)
sed -i 's/ORGANIZATION IS SEQUENTIAL/ORGANIZATION IS LINE SEQUENTIAL/g' \
    "$WORKDIR/HELLOBANK_TEST.cbl"
sed -i 's/PROGRAM-ID. HELLOBANK\./PROGRAM-ID. HELLOBANK-TEST./' \
    "$WORKDIR/HELLOBANK_TEST.cbl"

echo ">> Compilation..."
( cd "$WORKDIR" && cobc -x HELLOBANK_TEST.cbl )

echo ">> Execution..."
( cd "$WORKDIR" && \
  CLIENTI=CLIENTS.txt TRANSI=TRANS.txt REPORTO=REPORT.txt ./HELLOBANK_TEST )

echo ""
echo "================ RAPPORT GENERE ================"
cat "$WORKDIR/REPORT.txt"
echo "=================================================="
echo ""
echo ">> Test termine avec succes. Fichiers dans : $WORKDIR"
