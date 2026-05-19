#!/bin/bash

cd "$(dirname "$0")/.."

show_menu() {
    clear
    echo "========================================="
    echo "   GESTION HOPITAL v1.0"
    echo "   $(date '+%d/%m/%Y %H:%M')"
    echo "========================================="
    echo ""
    echo "┌─────────────────────────────────────┐"
    echo "│            MENU PRINCIPAL           │"
    echo "├─────────────────────────────────────┤"
    echo "│ 1. Gestion Patients                 │"
    echo "│ 2. Gestion Consultations            │"
    echo "│ 3. Gestion Factures                 │"
    echo "│ 4. Batch Quotidien                  │"
    echo "│ 5. Rapports                         │"
    echo "│ 6. Statistiques                     │"
    echo "│ 0. Quitter                          │"
    echo "└─────────────────────────────────────┘"
    echo -n "Choix : "
}

menu_patients() {
    while true; do
        clear
        echo "--- GESTION PATIENTS ---"
        echo "1. Lister patients"
        echo "2. Ajouter patient"
        echo "3. Rechercher patient"
        echo "0. Retour"
        echo -n "Choix : "
        read sub
        case $sub in
            1) bin/LISTER_PATIENTS ;;
            2) 
                read -p "ID (P000xx): " id
                read -p "NOM: " nom
                read -p "PRENOM: " prenom
                read -p "DATE NAISS (YYYY-MM-DD): " date
                read -p "SECU: " secu
                read -p "MUTUELLE: " mut
                read -p "CP: " cp
                echo -e "$id\n$nom\n$prenom\n$date\n$secu\n$mut\n$cp" | bin/AJOUT_PATIENT
                ;;
            3)
                read -p "ID: " id
                echo "$id" | bin/RECHERCHE_PATIENT
                ;;
            0) break ;;
        esac
        read -p "Appuyez sur Entrée..."
    done
}

menu_consultations() {
    while true; do
        clear
        echo "--- GESTION CONSULTATIONS ---"
        echo "1. Lister consultations"
        echo "2. Ajouter consultation"
        echo "0. Retour"
        echo -n "Choix : "
        read sub
        case $sub in
            1) bin/LISTER_CONSULTATIONS ;;
            2)
                read -p "ID PATIENT: " patient
                read -p "ID MEDECIN: " medecin
                read -p "DIAGNOSTIC: " diag
                echo -e "$patient\n$medecin\n$diag" | bin/AJOUT_CONSULTATION
                ;;
            0) break ;;
        esac
        read -p "Appuyez sur Entrée..."
    done
}

menu_factures() {
    while true; do
        clear
        echo "--- GESTION FACTURES ---"
        echo "1. Lister factures"
        echo "2. Generer facture"
        echo "3. Payer facture"
        echo "0. Retour"
        echo -n "Choix : "
        read sub
        case $sub in
            1) bin/LISTER_FACTURES ;;
            2)
                read -p "ID CONSULTATION: " id
                echo "$id" | bin/GENERER_FACTURE
                ;;
            3)
                read -p "ID FACTURE: " id
                echo "$id" | bin/PAYER_FACTURE
                ;;
            0) break ;;
        esac
        read -p "Appuyez sur Entrée..."
    done
}

run_batch() {
    clear
    echo "--- BATCH QUOTIDIEN ---"
    bin/BATCH_HOPITAL
    read -p "Appuyez sur Entrée..."
}

show_stats() {
    clear
    echo "=== STATISTIQUES HOPITAL ==="
    echo ""
    echo "Patients: $(wc -l < data/input/PATIENTS.DAT 2>/dev/null || echo 0)"
    echo "Medecins: $(wc -l < data/input/MEDECINS.DAT 2>/dev/null || echo 0)"
    echo "Consultations: $(wc -l < data/input/CONSULTATIONS.DAT 2>/dev/null || echo 0)"
    echo "Prescriptions: $(wc -l < data/input/PRESCRIPTIONS.DAT 2>/dev/null || echo 0)"
    echo "Factures: $(wc -l < data/input/FACTURES.DAT 2>/dev/null || echo 0)"
    read -p "Appuyez sur Entrée..."
}

show_reports() {
    clear
    echo "=== RAPPORTS ==="
    echo "1. Voir dernier rapport batch"
    echo "2. Liste des consultations"
    echo "3. Liste des factures impayees"
    echo -n "Choix : "
    read sub
    case $sub in
        1) cat data/output/reports/RAPPORT_HOPITAL.rpt 2>/dev/null || echo "Aucun rapport" ;;
        2) bin/LISTER_CONSULTATIONS ;;
        3) bin/LISTER_FACTURES | grep "I" ;;
    esac
    read -p "Appuyez sur Entrée..."
}

while true; do
    show_menu
    read choix
    case $choix in
        1) menu_patients ;;
        2) menu_consultations ;;
        3) menu_factures ;;
        4) run_batch ;;
        5) show_reports ;;
        6) show_stats ;;
        0) echo "Au revoir !"; exit 0 ;;
    esac
done
