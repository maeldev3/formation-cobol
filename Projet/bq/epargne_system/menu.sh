#!/bin/bash
# Menu principal du système d'épargne
BIN_DIR="bin"
SESSION_FILE="SESSION.DAT"

while true; do
    clear
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║           SYSTÈME DE GESTION D'ÉPARGNE                   ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║  1. Authentifier                                         ║"
    echo "║  2. Consulter solde                                      ║"
    echo "║  3. Déposer                                              ║"
    echo "║  4. Retirer                                              ║"
    echo "║  5. Calculer intérêts annuels                            ║"
    echo "║  6. Historique des opérations                            ║"
    echo "║  7. Déconnexion                                          ║"
    echo "║  0. Quitter                                              ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    read -p "Votre choix : " choix

    case $choix in
        1)
            $BIN_DIR/AUTHENTIFIER
            read -p "Appuyez sur Entrée..."
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
                $BIN_DIR/DEPOT
                read -p "Appuyez sur Entrée..."
            fi
            ;;
        4)
            if [ ! -f "$SESSION_FILE" ]; then
                echo "Veuillez d'abord vous authentifier."
                sleep 2
            else
                $BIN_DIR/RETRAIT
                read -p "Appuyez sur Entrée..."
            fi
            ;;
        5)
            if [ ! -f "$SESSION_FILE" ]; then
                echo "Veuillez d'abord vous authentifier."
                sleep 2
            else
                $BIN_DIR/CALCUL_INTERETS
                read -p "Appuyez sur Entrée..."
            fi
            ;;
        6)
            if [ ! -f "$SESSION_FILE" ]; then
                echo "Veuillez d'abord vous authentifier."
                sleep 2
            else
                $BIN_DIR/HISTORIQUE
                read -p "Appuyez sur Entrée..."
            fi
            ;;
        7)
            $BIN_DIR/LOGOUT 2>/dev/null
            rm -f SESSION.DAT
            echo "Déconnecté."
            sleep 1
            ;;
        0)
            rm -f SESSION.DAT 2>/dev/null
            echo "Au revoir !"
            exit 0
            ;;
        *)
            echo "Choix invalide"
            sleep 1
            ;;
    esac
done
