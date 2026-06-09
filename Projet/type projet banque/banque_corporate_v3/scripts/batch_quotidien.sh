#!/bin/bash
echo "=== BATCH QUOTIDIEN ==="
echo "Date: $(date +%Y-%m-%d)"
echo ""

report_file="data/output/reports/RAPPORT_JOURNALIER.rpt"
alert_file="data/output/reports/ALERTES.rpt"

echo "============================================" > $report_file
echo "RAPPORT BANCAIRE JOURNALIER DU $(date +%Y-%m-%d)" >> $report_file
echo "============================================" >> $report_file
echo "" >> $report_file

total_depots=$(grep "DEPOT" data/input/TRANSACTIONS.dat | grep "$(date +%Y-%m-%d)" | cut -d'|' -f4 | paste -sd+ | bc 2>/dev/null || echo 0)
total_retraits=$(grep "RETRAIT" data/input/TRANSACTIONS.dat | grep "$(date +%Y-%m-%d)" | cut -d'|' -f4 | paste -sd+ | bc 2>/dev/null || echo 0)
total_virements=$(grep "VIREMENT" data/input/TRANSACTIONS.dat | grep "$(date +%Y-%m-%d)" | cut -d'|' -f4 | paste -sd+ | bc 2>/dev/null || echo 0)
nb_transactions=$(grep "$(date +%Y-%m-%d)" data/input/TRANSACTIONS.dat | wc -l)

echo "--- RESUME DES TRANSACTIONS ---" >> $report_file
echo "Total depots: $total_depots €" >> $report_file
echo "Total retraits: $total_retraits €" >> $report_file
echo "Total virements: $total_virements €" >> $report_file
echo "Nombre transactions: $nb_transactions" >> $report_file
echo "" >> $report_file

echo "--- ALERTES ---" > $alert_file
awk -F'|' -v seuil=1000 '{if($4 < seuil) print "ALERTE: Compte " $1 " solde " $4 " €"}' data/input/COMPTES.dat >> $alert_file

echo "Batch quotidien terminé"
