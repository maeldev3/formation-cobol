#!/bin/bash

# Script de lancement ATM
cd "$(dirname "$0")/.."

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear_screen() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║                    ATM BANKING SYSTEM                        ║"
    echo "║                      Version 1.0                             ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_menu() {
    clear_screen
    echo ""
    echo -e "${YELLOW}1. Lancer l'ATM${NC}"
    echo -e "${YELLOW}2. Voir les donnees${NC}"
    echo -e "${YELLOW}3. Reinitialiser les donnees${NC}"
    echo -e "${YELLOW}4. Voir les transactions${NC}"
    echo -e "${RED}0. Quitter${NC}"
    echo ""
    echo -n "Choix : "
}

case $1 in
    --test)
        echo "Mode test ATM..."
        echo "1234567890123456" | bin/ATM
        ;;
    *)
        while true; do
            show_menu
            read choix
            case $choix in
                1)
                    clear_screen
                    bin/ATM
                    ;;
                2)
                    clear_screen
                    echo "=== CARTES ==="
                    cat data/input/CARTES.dat
                    echo ""
                    echo "=== COMPTES ==="
                    cat data/input/COMPTES.dat
                    read -p "Appuyez sur Entree..."
                    ;;
                3)
                    echo "Reinitialisation..."
                    cp data/input/CARTES.dat.bak data/input/CARTES.dat 2>/dev/null
                    cp data/input/COMPTES.dat.bak data/input/COMPTES.dat 2>/dev/null
                    echo "✓ Donnees reinitialisees"
                    read -p "Appuyez sur Entree..."
                    ;;
                4)
                    clear_screen
                    echo "=== TRANSACTIONS ==="
                    cat data/input/TRANSACTIONS.dat 2>/dev/null || echo "Aucune transaction"
                    read -p "Appuyez sur Entree..."
                    ;;
                0)
                    echo "Au revoir !"
                    exit 0
                    ;;
            esac
        done
        ;;
esac
