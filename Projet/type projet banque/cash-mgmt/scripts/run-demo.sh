#!/bin/bash
#============================================================
# run-demo.sh - Demo automatique Branch Cash Management
#============================================================
cd "$(dirname "$0")/.."

echo "=================================================="
echo "  DEMO - Branch Cash Management System"
echo "=================================================="

mkdir -p db bin

if [ ! -f bin/cash-main ]; then
    echo "Build en cours..."
    ./scripts/build.sh
fi

rm -f db/caisse.db

echo ""
echo "ETAPE 1: Initialisation base SQLite..."
./bin/cash-init
echo ""

echo "ETAPE 2: Session complete (ouverture + mouvements + cloture)..."
printf "AG001\nKAMIO Jean\n1\nO\n2\nDEP\n5000000\nDepot client RAKOTO\nTXN001\n2\nDEP\n2000000\nDepot RAZAFY\nTXN002\n3\nRET\n1500000\nRetrait RANDRIA\nTXN003\n3\nPAY\n800000\nPaiement facture EAU\nTXN004\n6\n7\n5\nO\n0\n" \
    | ./bin/cash-main
echo ""

echo "ETAPE 3: Verification base SQLite..."
sqlite3 db/caisse.db << 'SQL'
.headers on
.mode column
SELECT '=== CAISSES ===' as "";
SELECT id_caisse,id_agence,date_journee,
       solde_ouverture,total_entrees,total_sorties,
       solde_theorique,statut,caissier
FROM caisses;

SELECT '=== MOUVEMENTS ===' as "";
SELECT id_mouvement,date_op,heure_op,type_op,sens,
       montant,solde_apres,libelle
FROM mouvements;

SELECT '=== SOLDES AGENCES ===' as "";
SELECT id_agence,nom,solde_actuel FROM agences;
SQL

echo ""
echo "=================================================="
echo "  Demo terminee!"
echo "  Mode interactif : ./scripts/run.sh"
echo "  Inspecter DB    : sqlite3 db/caisse.db"
echo "=================================================="
