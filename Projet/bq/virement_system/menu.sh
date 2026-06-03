#!/bin/bash
BIN_DIR="bin"
SESSION_FILE="SESSION.DAT"

while true; do
    clear
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║           SYSTÈME DE GESTION DE VIREMENTS                ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║  1. Authentifier                                         ║"
    echo "║  2. Consulter solde                                      ║"
    echo "║  3. Virement interne                                     ║"
    echo "║  4. Virement externe                                     ║"
    echo "║  5. Historique des opérations                            ║"
    echo "║  6. Déconnexion                                          ║"
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
                $BIN_DIR/VIREMENT_INTERNE
                read -p "Appuyez sur Entrée..."
            fi
            ;;
        4)
            if [ ! -f "$SESSION_FILE" ]; then
                echo "Veuillez d'abord vous authentifier."
                sleep 2
            else
                $BIN_DIR/VIREMENT_EXTERNE
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
