#!/bin/bash
echo "=== BATCH MENSUEL - CALCUL DES INTERETS ==="
echo ""

report_file="data/output/reports/RAPPORT_MENSUEL.rpt"
mois=$(date +%Y-%m)

echo "============================================" > $report_file
echo "RAPPORT BANCAIRE MENSUEL - $mois" >> $report_file
echo "============================================" >> $report_file
echo "" >> $report_file

# Calcul des intérêts
taux=3.50
total_interets=0
nb_comptes=0

while IFS='|' read -r num client type solde decouvert date statut; do
    if [[ "$type" == "EPARGNE" ]]; then
        interet=$(echo "scale=2; $solde * $taux / 1200" | bc)
        total_interets=$(echo "$total_interets + $interet" | bc)
        nouveau_solde=$(echo "$solde + $interet" | bc)
        sed -i "s/^$num|$client|$type|$solde/$num|$client|$type|$nouveau_solde/" data/input/COMPTES.dat
        nb_comptes=$((nb_comptes + 1))
        echo "Compte $num - Interets: $interet €" >> $report_file
    fi
done < data/input/COMPTES.dat

echo "" >> $report_file
echo "Total interets verses: $total_interets €" >> $report_file
echo "Comptes majories: $nb_comptes" >> $report_file
echo "============================================" >> $report_file

echo "Batch mensuel terminé"
