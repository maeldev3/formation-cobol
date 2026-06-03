#!/bin/bash
# Menu principal ATM

SESSION_FILE="session.dat"
BIN_DIR="bin"
DATA_DIR="data"

# Vérifier base
if [ ! -f "$DATA_DIR/atm.db" ]; then
    echo "Base non trouvée. Lancez d'abord ./scripts/init_db.sh"
    exit 1
fi

while true; do
    clear
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                    ATM BANKING SYSTEM                    ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║  1. Authentifier                                         ║"
    echo "║  2. Consulter solde                                      ║"
    echo "║  3. Retirer                                              ║"
    echo "║  4. Déposer                                              ║"
    echo "║  5. Mini-relevé                                          ║"
    echo "║  6. Déconnexion                                          ║"
    echo "║  0. Quitter                                              ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    read -p "Votre choix : " choix

    case $choix in
      # Dans menu.sh, option 1 :
       1)
            $BIN_DIR/AUTHENTIFIER
            if [ -f "SESSION.DAT" ]; then
                # Enchaîner sur le menu des opérations
                while true; do
                    echo "1. Solde  2. Retrait  3. Dépôt  4. Historique  0. Déconnexion"
                    read sub
                    case $sub in
                        1) $BIN_DIR/SOLDE;;
                        2) $BIN_DIR/RETRAIT;;
                        3) $BIN_DIR/DEPOT;;
                        4) $BIN_DIR/HISTORIQUE;;
                        0) $BIN_DIR/LOGOUT; break;;
                    esac
                done
            fi
            ;;
        2)
            if [ ! -f "$SESSION_FILE" ]; then
                echo "Veuillez d'abord vous authentifier."
                sleep 2
            else
                $BIN_DIR/SOLDE
                read -p "Appuyez sur Entrée..."
            fi
            ;;
        3)
            if [ ! -f "$SESSION_FILE" ]; then
                echo "Veuillez d'abord vous authentifier."
                sleep 2
            else
                $BIN_DIR/RETRAIT
                read -p "Appuyez sur Entrée..."
            fi
            ;;
        4)
            if [ ! -f "$SESSION_FILE" ]; then
                echo "Veuillez d'abord vous authentifier."
                sleep 2
            else
                $BIN_DIR/DEPOT
                read -p "Appuyez sur Entrée..."
            fi
            ;;
        5)
            if [ ! -f "$SESSION_FILE" ]; then
                echo "Veuillez d'abord vous authentifier."
                sleep 2
            else
                $BIN_DIR/HISTORIQUE
                read -p "Appuyez sur Entrée..."
            fi
            ;;
        6)
            $BIN_DIR/LOGOUT
            sleep 1
            ;;
        0)
            $BIN_DIR/LOGOUT 2>/dev/null
            echo "Au revoir !"
            exit 0
            ;;
        *)
            echo "Choix invalide"
            sleep 1
            ;;
    esac
done
