#!/bin/bash

cd "$(dirname "$0")/.."

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear_screen() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                              ║"
    echo "║                 SYSTÈME BANCAIRE CORPORATE V3.0                              ║"
    echo "║              PLATEFORME BANCAIRE MULTI-AGENCES                               ║"
    echo "║                                                                              ║"
    echo "║                      $(date '+%d/%m/%Y %H:%M:%S')                            ║"
    echo "║                                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_main_menu() {
    clear_screen
    echo ""
    echo -e "${YELLOW}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│                              MENU PRINCIPAL                                 │${NC}"
    echo -e "${YELLOW}├─────────────────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${GREEN}│  1. 🏛️  Gestion des Clients                                                  │${NC}"
    echo -e "${GREEN}│  2. 🏦  Gestion des Comptes                                                  │${NC}"
    echo -e "${GREEN}│  3. 💳  Gestion des Cartes                                                   │${NC}"
    echo -e "${GREEN}│  4. 💰  Gestion des Transactions                                            │${NC}"
    echo -e "${GREEN}│  5. 📊  Gestion des Crédits                                                  │${NC}"
    echo -e "${GREEN}│  6. 📍  Gestion des Agences                                                  │${NC}"
    echo -e "${GREEN}│  7. 👥  Gestion des Utilisateurs                                             │${NC}"
    echo -e "${GREEN}│  8. ⚙️  Batch & Rapports                                                     │${NC}"
    echo -e "${GREEN}│  9. 📈  Statistiques                                                         │${NC}"
    echo -e "${RED}│  0. 🚪  Quitter                                                              │${NC}"
    echo -e "${YELLOW}└─────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo -n "Choix : "
}

menu_clients() {
    while true; do
        clear_screen
        echo ""
        echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}│                           GESTION DES CLIENTS                               │${NC}"
        echo -e "${CYAN}├─────────────────────────────────────────────────────────────────────────────┤${NC}"
        echo -e "${GREEN}│  1. 📋 Lister tous les clients                                              │${NC}"
        echo -e "${GREEN}│  2. ➕ Ajouter un client                                                    │${NC}"
        echo -e "${GREEN}│  3. 🔍 Rechercher un client                                                 │${NC}"
        echo -e "${GREEN}│  4. ✏️  Modifier un client                                                  │${NC}"
        echo -e "${GREEN}│  5. 🗑️  Supprimer un client                                                 │${NC}"
        echo -e "${RED}│  0. ↩️  Retour                                                              │${NC}"
        echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────┘${NC}"
        echo -n "Choix : "
        read sub
        
        case $sub in
            1)
                echo ""
                echo "=== LISTE DES CLIENTS ==="
                if [ -f "data/input/CLIENTS.dat" ]; then
                    awk -F'|' 'BEGIN {printf "%-8s %-25s %-12s %-10s\n", "ID", "NOM COMPLET", "TELEPHONE", "CATEGORIE"}
                    {printf "%-8s %-25s %-12s %-10s\n", $1, $2" "$3, $7, $11}' data/input/CLIENTS.dat
                else
                    echo "Aucun client trouve"
                fi
                ;;
            2)
                echo ""
                echo "=== AJOUTER UN CLIENT ==="
                read -p "ID (ex: C00011): " id
                read -p "NOM: " nom
                read -p "PRENOM: " prenom
                read -p "ADRESSE: " adresse
                read -p "CODE POSTAL: " cp
                read -p "VILLE: " ville
                read -p "TELEPHONE: " tel
                read -p "EMAIL: " email
                read -p "REVENU ANNUEL: " revenu
                
                if [ $revenu -gt 100000 ]; then
                    categ="GOLD"
                elif [ $revenu -gt 70000 ]; then
                    categ="PREMIUM"
                else
                    categ="CLASSIC"
                fi
                
                echo "$id|$nom|$prenom|$adresse|$cp|$ville|$tel|$email|$revenu|$(date +%Y-%m-%d)|$categ|ACTIF" >> data/input/CLIENTS.dat
                echo -e "${GREEN}✓ Client ajoute avec succes${NC}"
                ;;
            3)
                echo ""
                read -p "ID Client a rechercher: " id
                echo ""
                grep "^$id|" data/input/CLIENTS.dat | awk -F'|' '{printf "ID: %s\nNOM: %s %s\nADRESSE: %s %s %s\nTEL: %s\nEMAIL: %s\nREVENU: %s €\nCATEGORIE: %s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, $11}'
                ;;
            4)
                echo ""
                read -p "ID Client a modifier: " id
                read -p "NOUVEAU TELEPHONE: " tel
                sed -i "s/^$id|[^|]*|[^|]*|[^|]*|[^|]*|[^|]*|[^|]*/$id|$tel/" data/input/CLIENTS.dat
                echo -e "${GREEN}✓ Client modifie${NC}"
                ;;
            5)
                echo ""
                read -p "ID Client a supprimer: " id
                read -p "Confirmer (O/N): " conf
                if [[ "$conf" =~ ^[Oo]$ ]]; then
                    sed -i "/^$id|/d" data/input/CLIENTS.dat
                    echo -e "${GREEN}✓ Client supprime${NC}"
                fi
                ;;
            0) break ;;
        esac
        read -p "Appuyez sur Entree..."
    done
}

menu_transactions() {
    while true; do
        clear_screen
        echo ""
        echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}│                         GESTION DES TRANSACTIONS                            │${NC}"
        echo -e "${CYAN}├─────────────────────────────────────────────────────────────────────────────┤${NC}"
        echo -e "${GREEN}│  1. 💵 Depot                                                                │${NC}"
        echo -e "${GREEN}│  2. 💸 Retrait                                                              │${NC}"
        echo -e "${GREEN}│  3. 🔄 Virement                                                             │${NC}"
        echo -e "${GREEN}│  4. 📜 Historique des transactions                                          │${NC}"
        echo -e "${RED}│  0. ↩️  Retour                                                              │${NC}"
        echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────┘${NC}"
        echo -n "Choix : "
        read sub
        
        case $sub in
            1)
                echo ""
                read -p "NUMERO COMPTE: " compte
                read -p "MONTANT: " montant
                
                solde=$(grep "^$compte|" data/input/COMPTES.dat | cut -d'|' -f4)
                if [ -z "$solde" ]; then
                    echo -e "${RED}Erreur: Compte inexistant${NC}"
                else
                    id="DEP$(date +%Y%m%d%H%M%S)"
                    echo "$id|$compte|$(date +%Y-%m-%d)|$montant|DEPOT|ESPECES|VALIDEE" >> data/input/TRANSACTIONS.dat
                    nouveau_solde=$(echo "$solde + $montant" | bc)
                    sed -i "s/^$compte|[^|]*|[^|]*|$solde/$compte|$nouveau_solde/" data/input/COMPTES.dat
                    echo -e "${GREEN}✓ Depot effectue. Nouveau solde: $nouveau_solde €${NC}"
                fi
                ;;
            2)
                echo ""
                read -p "NUMERO COMPTE: " compte
                read -p "MONTANT: " montant
                
                solde=$(grep "^$compte|" data/input/COMPTES.dat | cut -d'|' -f4)
                if [ -z "$solde" ]; then
                    echo -e "${RED}Erreur: Compte inexistant${NC}"
                elif (( $(echo "$montant > $solde" | bc -l) )); then
                    echo -e "${RED}Erreur: Solde insuffisant${NC}"
                else
                    id="RET$(date +%Y%m%d%H%M%S)"
                    echo "$id|$compte|$(date +%Y-%m-%d)|$montant|RETRAIT|ESPECES|VALIDEE" >> data/input/TRANSACTIONS.dat
                    nouveau_solde=$(echo "$solde - $montant" | bc)
                    sed -i "s/^$compte|[^|]*|[^|]*|$solde/$compte|$nouveau_solde/" data/input/COMPTES.dat
                    echo -e "${GREEN}✓ Retrait effectue. Nouveau solde: $nouveau_solde €${NC}"
                fi
                ;;
            3)
                echo ""
                read -p "COMPTE EMETTEUR: " emet
                read -p "COMPTE DESTINATAIRE: " dest
                read -p "MONTANT: " montant
                
                solde_emet=$(grep "^$emet|" data/input/COMPTES.dat | cut -d'|' -f4)
                solde_dest=$(grep "^$dest|" data/input/COMPTES.dat | cut -d'|' -f4)
                
                if [ -z "$solde_emet" ] || [ -z "$solde_dest" ]; then
                    echo -e "${RED}Erreur: Compte inexistant${NC}"
                elif (( $(echo "$montant > $solde_emet" | bc -l) )); then
                    echo -e "${RED}Erreur: Solde insuffisant${NC}"
                else
                    id="VIR$(date +%Y%m%d%H%M%S)"
                    echo "$id|$emet|$(date +%Y-%m-%d)|$montant|VIREMENT|SEPA|VALIDEE" >> data/input/TRANSACTIONS.dat
                    nouveau_solde_emet=$(echo "$solde_emet - $montant" | bc)
                    nouveau_solde_dest=$(echo "$solde_dest + $montant" | bc)
                    sed -i "s/^$emet|[^|]*|[^|]*|$solde_emet/$emet|$nouveau_solde_emet/" data/input/COMPTES.dat
                    sed -i "s/^$dest|[^|]*|[^|]*|$solde_dest/$dest|$nouveau_solde_dest/" data/input/COMPTES.dat
                    echo -e "${GREEN}✓ Virement effectue${NC}"
                fi
                ;;
            4)
                echo ""
                read -p "NUMERO COMPTE: " compte
                echo ""
                echo "=== HISTORIQUE DES TRANSACTIONS ==="
                echo "DATE       | TYPE       | MONTANT   | STATUT"
                echo "-----------|------------|-----------|--------"
                grep "$compte" data/input/TRANSACTIONS.dat | awk -F'|' '{printf "%-10s | %-10s | %9s € | %-7s\n", $3, $5, $4, $7}'
                ;;
            0) break ;;
        esac
        read -p "Appuyez sur Entree..."
    done
}

show_stats() {
    clear_screen
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│                           STATISTIQUES BANCAIRES                            │${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────────────────────────────────────┤${NC}"
    
    nb_clients=$(grep -c "ACTIF" data/input/CLIENTS.dat 2>/dev/null || echo 0)
    nb_comptes=$(wc -l < data/input/COMPTES.dat 2>/dev/null || echo 0)
    nb_transactions=$(wc -l < data/input/TRANSACTIONS.dat 2>/dev/null || echo 0)
    
    total_depots=$(grep "DEPOT" data/input/TRANSACTIONS.dat 2>/dev/null | cut -d'|' -f4 | paste -sd+ | bc 2>/dev/null || echo 0)
    total_retraits=$(grep "RETRAIT" data/input/TRANSACTIONS.dat 2>/dev/null | cut -d'|' -f4 | paste -sd+ | bc 2>/dev/null || echo 0)
    
    echo -e "${GREEN}│  Clients actifs      : $nb_clients                                                      │${NC}"
    echo -e "${GREEN}│  Comptes ouverts     : $nb_comptes                                                      │${NC}"
    echo -e "${GREEN}│  Transactions        : $nb_transactions                                                 │${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${GREEN}│  Total depots        : $total_depots €                                                │${NC}"
    echo -e "${GREEN}│  Total retraits      : $total_retraits €                                                │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────┘${NC}"
    
    read -p "Appuyez sur Entree..."
}

# Menu principal
while true; do
    show_main_menu
    read choix
    case $choix in
        1) menu_clients ;;
        2) 
            clear_screen
            echo "=== LISTE DES COMPTES ==="
            awk -F'|' '{printf "%-8s %-10s %12s €\n", $1, $3, $4}' data/input/COMPTES.dat
            read -p "Appuyez sur Entree..."
            ;;
        3) 
            clear_screen
            echo "=== LISTE DES CARTES ==="
            if [ -f "data/input/CARTES.dat" ]; then
                awk -F'|' '{printf "%-8s %-8s %-15s %-10s %-8s\n", $1, $2, $11, $10, $9}' data/input/CARTES.dat
            else
                echo "Aucune carte trouvee"
            fi
            read -p "Appuyez sur Entree..."
            ;;
        4) menu_transactions ;;
        5) 
            clear_screen
            echo "=== LISTE DES CREDITS ==="
            if [ -f "data/input/CREDITS.dat" ]; then
                awk -F'|' '{printf "%-8s %-8s %10s € %5s%% %5s mois\n", $1, $2, $3, $4, $5}' data/input/CREDITS.dat
            else
                echo "Aucun credit trouve"
            fi
            read -p "Appuyez sur Entree..."
            ;;
        6)
            clear_screen
            echo "=== LISTE DES AGENCES ==="
            awk -F'|' '{printf "%-8s %-20s %-15s\n", $1, $2, $3}' data/input/AGENCES.dat
            read -p "Appuyez sur Entree..."
            ;;
        7)
            clear_screen
            echo "=== LISTE DES UTILISATEURS ==="
            awk -F'|' '{printf "%-8s %-12s %-15s %-10s\n", $1, $2, $5, $8}' data/input/UTILISATEURS.dat
            read -p "Appuyez sur Entree..."
            ;;
        8)
            clear_screen
            echo "=== BATCH & RAPPORTS ==="
            echo "1. Executer batch quotidien"
            echo "2. Executer batch mensuel"
            read -p "Choix: " batch_choice
            if [ "$batch_choice" = "1" ]; then
                if [ -f "bin/BATCH_QUOTIDIEN" ]; then
                    bin/BATCH_QUOTIDIEN
                else
                    echo "Batch quotidien non compile"
                fi
            elif [ "$batch_choice" = "2" ]; then
                if [ -f "bin/BATCH_MENSUEL" ]; then
                    bin/BATCH_MENSUEL
                else
                    echo "Batch mensuel non compile"
                fi
            fi
            read -p "Appuyez sur Entree..."
            ;;
        9) show_stats ;;
        0) echo -e "${GREEN}Au revoir !${NC}" ; exit 0 ;;
    esac
done
