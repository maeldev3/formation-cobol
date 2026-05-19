#!/bin/bash

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BIN_DIR="$PROJECT_DIR/bin"
DATA_DIR="$PROJECT_DIR/data"
LOG_DIR="$DATA_DIR/output/logs"

mkdir -p "$LOG_DIR"

show_menu() {
    clear
    echo "========================================="
    echo "   SYSTEME ASSURANCE v1.0"
    echo "   $(date '+%d/%m/%Y %H:%M')"
    echo "========================================="
    echo ""
    echo "┌─────────────────────────────────────┐"
    echo "│            MENU PRINCIPAL           │"
    echo "├─────────────────────────────────────┤"
    echo "│ 1. Gestion Clients                  │"
    echo "│ 2. Gestion Contrats                 │"
    echo "│ 3. Gestion Sinistres                │"
    echo "│ 4. Gestion Paiements                │"
    echo "│ 5. Batch Quotidien                  │"
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
            1) [ -f "$BIN_DIR/LISTER_CLIENTS" ] && "$BIN_DIR/LISTER_CLIENTS" || echo "Module non disponible" ;;
            2) 
                if [ -f "$BIN_DIR/AJOUT_CLIENT" ]; then
                    read -p "ID (C000xx): " id
                    read -p "NOM: " nom
                    read -p "PRENOM: " prenom
                    read -p "ADRESSE: " adresse
                    read -p "TEL: " tel
                    echo -e "$id\n$nom\n$prenom\n$adresse\n$tel" | "$BIN_DIR/AJOUT_CLIENT"
                else
                    echo "Module non disponible"
                fi
                ;;
            3) 
                [ -f "$BIN_DIR/RECHERCHE_CLIENT" ] && (read -p "ID: " id; echo "$id" | "$BIN_DIR/RECHERCHE_CLIENT") || echo "Module non disponible"
                ;;
            0) break ;;
        esac
        read -p "Appuyez sur Entrée..."
    done
}

menu_contrats() {
    while true; do
        clear
        echo "--- GESTION CONTRATS ---"
        echo "1. Lister contrats"
        echo "2. Creer contrat"
        echo "0. Retour"
        echo -n "Choix : "
        read sub
        
        case $sub in
            1) [ -f "$BIN_DIR/LISTER_CONTRATS" ] && "$BIN_DIR/LISTER_CONTRATS" || echo "Module non disponible" ;;
            2) 
                if [ -f "$BIN_DIR/CREER_CONTRAT" ]; then
                    read -p "NUMERO (AUTOxxx): " num
                    read -p "ID CLIENT: " id
                    read -p "TYPE (AUTO/SANT/HABI): " type
                    read -p "PRIME: " prime
                    echo -e "$num\n$id\n$type\n$prime\n$(date +%Y-%m-%d)" | "$BIN_DIR/CREER_CONTRAT"
                else
                    echo "Module non disponible"
                fi
                ;;
            0) break ;;
        esac
        read -p "Appuyez sur Entrée..."
    done
}

menu_sinistres() {
    while true; do
        clear
        echo "--- GESTION SINISTRES ---"
        echo "1. Lister sinistres"
        echo "2. Declarer sinistre"
        echo "3. Traiter sinistre"
        echo "0. Retour"
        echo -n "Choix : "
        read sub
        
        case $sub in
            1) [ -f "$BIN_DIR/LISTER_SINISTRES" ] && "$BIN_DIR/LISTER_SINISTRES" || echo "Module non disponible" ;;
            2) 
                if [ -f "$BIN_DIR/DECLARER_SINISTRE" ]; then
                    read -p "NUMERO CONTRAT: " contrat
                    read -p "MONTANT: " montant
                    echo -e "$contrat\n$montant" | "$BIN_DIR/DECLARER_SINISTRE"
                else
                    echo "Module non disponible"
                fi
                ;;
            3)
                if [ -f "$BIN_DIR/TRAITER_SINISTRE" ]; then
                    read -p "ID SINISTRE: " id
                    read -p "STATUS (T=Traite/R=Rejete): " status
                    echo -e "$id\n$status" | "$BIN_DIR/TRAITER_SINISTRE"
                else
                    echo "Module non disponible"
                fi
                ;;
            0) break ;;
        esac
        read -p "Appuyez sur Entrée..."
    done
}

menu_paiements() {
    while true; do
        clear
        echo "--- GESTION PAIEMENTS ---"
        echo "1. Lister paiements"
        echo "2. Indemniser sinistre"
        echo "0. Retour"
        echo -n "Choix : "
        read sub
        
        case $sub in
            1) [ -f "$BIN_DIR/LISTER_PAIEMENTS" ] && "$BIN_DIR/LISTER_PAIEMENTS" || echo "Module non disponible" ;;
            2) 
                if [ -f "$BIN_DIR/INDEMNISER" ]; then
                    read -p "ID SINISTRE: " id
                    read -p "MONTANT: " montant
                    echo -e "$id\n$montant" | "$BIN_DIR/INDEMNISER"
                else
                    echo "Module non disponible"
                fi
                ;;
            0) break ;;
        esac
        read -p "Appuyez sur Entrée..."
    done
}

run_batch() {
    clear
    echo "--- BATCH QUOTIDIEN ---"
    if [ -f "$BIN_DIR/BATCH_QUOTIDIEN" ]; then
        "$BIN_DIR/BATCH_QUOTIDIEN"
    else
        echo "Module BATCH_QUOTIDIEN non disponible"
    fi
    read -p "Appuyez sur Entrée..."
}

show_stats() {
    clear
    echo "=== STATISTIQUES ==="
    echo ""
    echo "Clients: $(wc -l < "$DATA_DIR/input/CLIENTS.DAT" 2>/dev/null || echo 0)"
    echo "Contrats: $(wc -l < "$DATA_DIR/input/CONTRATS.DAT" 2>/dev/null || echo 0)"
    echo "Sinistres: $(wc -l < "$DATA_DIR/input/SINISTRES.DAT" 2>/dev/null || echo 0)"
    echo "Paiements: $(wc -l < "$DATA_DIR/input/PAIEMENTS.DAT" 2>/dev/null || echo 0)"
    read -p "Appuyez sur Entrée..."
}

main() {
    while true; do
        show_menu
        read choix
        
        case $choix in
            1) menu_clients ;;
            2) menu_contrats ;;
            3) menu_sinistres ;;
            4) menu_paiements ;;
            5) run_batch ;;
            6) show_stats ;;
            0) echo "Au revoir !"; exit 0 ;;
            *) echo "Option invalide" ;;
        esac
    done
}

main "$@"
