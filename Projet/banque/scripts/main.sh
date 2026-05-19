#!/bin/bash

cd "$(dirname "$0")/.."

show_menu() {
    clear
    echo "========================================="
    echo "   SYSTEME BANQUE v1.0"
    echo "   $(date '+%d/%m/%Y %H:%M')"
    echo "========================================="
    echo ""
    echo "┌─────────────────────────────────────┐"
    echo "│            MENU PRINCIPAL           │"
    echo "├─────────────────────────────────────┤"
    echo "│ 1. Gestion Clients                  │"
    echo "│ 2. Gestion Comptes                  │"
    echo "│ 3. Transactions                     │"
    echo "│ 4. Batch Mensuel                    │"
    echo "│ 5. Rapports                         │"
    echo "│ 6. Statistiques                     │"
    echo "│ 0. Quitter                          │"
    echo "└─────────────────────────────────────┘"
    echo -n "Choix : "
}

menu_clients() {
    while true; do
        clear
        echo "--- GESTION CLIENTS ---"
        echo "1. Lister clients"
        echo "2. Ajouter client"
        echo "3. Rechercher client"
        echo "0. Retour"
        echo -n "Choix : "
        read sub
        case $sub in
            1) bin/LISTER_CLIENTS ;;
            2) 
                read -p "ID (B00011): " id
                read -p "NOM: " nom
                read -p "PRENOM: " prenom
                read -p "ADRESSE: " adresse
                read -p "TEL: " tel
                read -p "REVENU: " revenu
                echo -e "$id\n$nom\n$prenom\n$adresse\n$tel\n$revenu" | bin/AJOUT_CLIENT
                ;;
            3)
                read -p "ID: " id
                echo "$id" | bin/RECHERCHE_CLIENT
                ;;
            0) break ;;
        esac
        read -p "Appuyez sur Entrée..."
    done
}

menu_comptes() {
    while true; do
        clear
        echo "--- GESTION COMPTES ---"
        echo "1. Lister comptes"
        echo "2. Ajouter compte"
        echo "3. Consulter solde"
        echo "0. Retour"
        echo -n "Choix : "
        read sub
        case $sub in
            1) bin/LISTER_COMPTES ;;
            2)
                read -p "ID CLIENT: " id
                read -p "TYPE (COUR/EPAR): " type
                read -p "SOLDE INITIAL: " solde
                echo -e "$id\n$type\n$solde" | bin/AJOUT_COMPTE
                ;;
            3)
                read -p "NUMERO COMPTE: " num
                echo "$num" | bin/CONSULTER_SOLDE
                ;;
            0) break ;;
        esac
        read -p "Appuyez sur Entrée..."
    done
}

menu_transactions() {
    while true; do
        clear
        echo "--- TRANSACTIONS ---"
        echo "1. Depot"
        echo "2. Retrait"
        echo "3. Virement"
        echo "4. Historique"
        echo "0. Retour"
        echo -n "Choix : "
        read sub
        case $sub in
            1)
                read -p "COMPTE: " num
                read -p "MONTANT: " mt
                echo -e "$num\n$mt" | bin/DEPOT
                ;;
            2)
                read -p "COMPTE: " num
                read -p "MONTANT: " mt
                echo -e "$num\n$mt" | bin/RETRAIT
                ;;
            3)
                read -p "COMPTE EMETTEUR: " emet
                read -p "COMPTE DEST: " dest
                read -p "MONTANT: " mt
                echo -e "$emet\n$dest\n$mt" | bin/VIREMENT
                ;;
            4)
                read -p "COMPTE: " num
                echo "$num" | bin/HISTORIQUE_TRANSACTIONS
                ;;
            0) break ;;
        esac
        read -p "Appuyez sur Entrée..."
    done
}

run_batch() {
    clear
    echo "--- BATCH MENSUEL ---"
    bin/BATCH_BANQUE
    read -p "Appuyez sur Entrée..."
}

show_reports() {
    clear
    echo "=== RAPPORTS ==="
    echo "1. Rapport mensuel"
    echo "2. Liste des comptes"
    echo "3. Historique des transactions"
    echo -n "Choix : "
    read sub
    case $sub in
        1) cat data/output/reports/RAPPORT_BANQUE.rpt 2>/dev/null || echo "Aucun rapport" ;;
        2) bin/LISTER_COMPTES ;;
        3)
            read -p "COMPTE: " num
            echo "$num" | bin/HISTORIQUE_TRANSACTIONS
            ;;
    esac
    read -p "Appuyez sur Entrée..."
}

show_stats() {
    clear
    echo "=== STATISTIQUES BANQUE ==="
    echo ""
    echo "Clients: $(wc -l < data/input/CLIENTS.DAT 2>/dev/null || echo 0)"
    echo "Comptes: $(wc -l < data/input/COMPTES.DAT 2>/dev/null || echo 0)"
    echo "Transactions: $(wc -l < data/input/TRANSACTIONS.DAT 2>/dev/null || echo 0)"
    echo "Credits: $(wc -l < data/input/CREDITS.DAT 2>/dev/null || echo 0)"
    read -p "Appuyez sur Entrée..."
}

while true; do
    show_menu
    read choix
    case $choix in
        1) menu_clients ;;
        2) menu_comptes ;;
        3) menu_transactions ;;
        4) run_batch ;;
        5) show_reports ;;
        6) show_stats ;;
        0) echo "Au revoir !"; exit 0 ;;
    esac
done
