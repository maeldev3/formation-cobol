#!/bin/bash

# Menu principal en bash (solution de contournement)
while true; do
    clear
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    HOTEL PARADISE                            ║"
    echo "║              SYSTEME COMPLET DE GESTION                      ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║  1. GESTION CLIENTS (CRUD)                                   ║"
    echo "║  2. GESTION CHAMBRES (CRUD)                                  ║"
    echo "║  3. GESTION RESERVATIONS (CRUD)                              ║"
    echo "║  4. RAPPORTS                                                 ║"
    echo "║  0. QUITTER                                                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    read -p "Choix : " choix

    case $choix in
        1)
            while true; do
                echo ""
                echo "╔════════════════════════════════════════════════════╗"
                echo "║               GESTION CLIENTS (CRUD)               ║"
                echo "╠════════════════════════════════════════════════════╣"
                echo "║  1. CREER   - Ajouter un client                    ║"
                echo "║  2. LIRE    - Lister les clients                   ║"
                echo "║  3. LIRE    - Rechercher un client                 ║"
                echo "║  4. MODIFIER- Modifier un client                   ║"
                echo "║  5. SUPPRIMER- Supprimer un client                 ║"
                echo "║  0. Retour                                         ║"
                echo "╚════════════════════════════════════════════════════╝"
                read -p "Choix : " sub_choix
                
                case $sub_choix in
                    1)
                        echo ""
                        read -p "ID Client (C00001): " id
                        read -p "NOM: " nom
                        read -p "PRENOM: " prenom
                        read -p "EMAIL: " email
                        read -p "TELEPHONE: " tel
                        read -p "ADRESSE: " adresse
                        sqlite3 data/input/hotel.db "INSERT INTO CLIENTS (ID_CLIENT, NOM, PRENOM, EMAIL, TELEPHONE, ADRESSE, STATUT) VALUES ('$id', '$nom', '$prenom', '$email', '$tel', '$adresse', 'ACTIF');"
                        echo "✓ Client créé avec succès"
                        read -p "Appuyez sur Entrée..."
                        ;;
                    2)
                        echo ""
                        echo "========================================="
                        echo "         LISTE DES CLIENTS"
                        echo "========================================="
                        sqlite3 data/input/hotel.db "SELECT ID_CLIENT || ' | ' || NOM || ' ' || PRENOM || ' | ' || TELEPHONE FROM CLIENTS;"
                        echo "========================================="
                        read -p "Appuyez sur Entrée..."
                        ;;
                    3)
                        echo ""
                        read -p "ID Client à rechercher: " id
                        echo ""
                        sqlite3 data/input/hotel.db "SELECT 'ID: ' || ID_CLIENT || CHAR(10) || 'NOM: ' || NOM || CHAR(10) || 'PRENOM: ' || PRENOM || CHAR(10) || 'TEL: ' || TELEPHONE FROM CLIENTS WHERE ID_CLIENT='$id';"
                        read -p "Appuyez sur Entrée..."
                        ;;
                    4)
                        echo ""
                        read -p "ID Client à modifier: " id
                        read -p "NOUVEAU TELEPHONE: " tel
                        sqlite3 data/input/hotel.db "UPDATE CLIENTS SET TELEPHONE='$tel' WHERE ID_CLIENT='$id';"
                        echo "✓ Client modifié"
                        read -p "Appuyez sur Entrée..."
                        ;;
                    5)
                        echo ""
                        read -p "ID Client à supprimer: " id
                        read -p "Confirmer (O/N): " conf
                        if [ "$conf" = "O" ] || [ "$conf" = "o" ]; then
                            sqlite3 data/input/hotel.db "DELETE FROM CLIENTS WHERE ID_CLIENT='$id';"
                            echo "✓ Client supprimé"
                        else
                            echo "Annulé"
                        fi
                        read -p "Appuyez sur Entrée..."
                        ;;
                    0)
                        break
                        ;;
                esac
            done
            ;;
        2)
            while true; do
                echo ""
                echo "╔════════════════════════════════════════════════════╗"
                echo "║               GESTION CHAMBRES (CRUD)              ║"
                echo "╠════════════════════════════════════════════════════╣"
                echo "║  1. CREER   - Ajouter une chambre                  ║"
                echo "║  2. LIRE    - Lister les chambres                  ║"
                echo "║  3. MODIFIER- Modifier statut chambre              ║"
                echo "║  0. Retour                                         ║"
                echo "╚════════════════════════════════════════════════════╝"
                read -p "Choix : " sub_choix
                
                case $sub_choix in
                    1)
                        echo ""
                        read -p "ID Chambre (CH001): " id
                        read -p "Numero: " numero
                        read -p "Type (Standard/Confort/Suite): " type
                        read -p "Prix: " prix
                        sqlite3 data/input/hotel.db "INSERT INTO CHAMBRES VALUES ('$id', '$numero', '$type', $prix, 'DISPONIBLE');"
                        echo "✓ Chambre créée"
                        read -p "Appuyez sur Entrée..."
                        ;;
                    2)
                        echo ""
                        echo "========================================="
                        echo "         LISTE DES CHAMBRES"
                        echo "========================================="
                        sqlite3 data/input/hotel.db "SELECT ID_CHAMBRE || ' | ' || NUMERO || ' | ' || TYPE || ' | ' || PRIX || '€ | ' || STATUT FROM CHAMBRES;"
                        echo "========================================="
                        read -p "Appuyez sur Entrée..."
                        ;;
                    3)
                        echo ""
                        read -p "ID Chambre: " id
                        read -p "Statut (DISPONIBLE/OCCUPEE/RESERVEE): " statut
                        sqlite3 data/input/hotel.db "UPDATE CHAMBRES SET STATUT='$statut' WHERE ID_CHAMBRE='$id';"
                        echo "✓ Statut modifié"
                        read -p "Appuyez sur Entrée..."
                        ;;
                    0)
                        break
                        ;;
                esac
            done
            ;;
        3)
            while true; do
                echo ""
                echo "╔════════════════════════════════════════════════════╗"
                echo "║             GESTION RESERVATIONS (CRUD)            ║"
                echo "╠════════════════════════════════════════════════════╣"
                echo "║  1. CREER   - Creer une reservation                ║"
                echo "║  2. LIRE    - Lister les reservations              ║"
                echo "║  3. MODIFIER- Annuler une reservation              ║"
                echo "║  0. Retour                                         ║"
                echo "╚════════════════════════════════════════════════════╝"
                read -p "Choix : " sub_choix
                
                case $sub_choix in
                      1)
                        echo ""
                        read -p "ID Client: " client
                        read -p "ID Chambre: " chambre
                        read -p "Date debut (YYYY-MM-DD): " debut
                        read -p "Date fin (YYYY-MM-DD): " fin
                        read -p "Nombre de personnes: " nb_personnes
                        read -p "Montant total: " montant
                        id="RES$(date +%Y%m%d%H%M%S)"
                        date_reservation=$(date +%Y-%m-%d)
                        
                        sqlite3 data/input/hotel.db "INSERT INTO RESERVATIONS (ID_RESERVATION, ID_CLIENT, ID_CHAMBRE, DATE_DEBUT, DATE_FIN, NB_PERSONNES, STATUT, DATE_RESERVATION, MONTANT_TOTAL) VALUES ('$id', '$client', '$chambre', '$debut', '$fin', $nb_personnes, 'CONFIRMEE', '$date_reservation', $montant);"
                        
                        sqlite3 data/input/hotel.db "UPDATE CHAMBRES SET STATUT='RESERVEE' WHERE ID_CHAMBRE='$chambre';"
                        
                        echo "✓ Réservation créée: $id"
                        read -p "Appuyez sur Entrée..."
                        ;;
                    2)
                        echo ""
                        echo "========================================="
                        echo "      LISTE DES RESERVATIONS"
                        echo "========================================="
                        sqlite3 data/input/hotel.db "SELECT ID_RESERVATION || ' | ' || ID_CLIENT || ' | ' || ID_CHAMBRE || ' | ' || DATE_DEBUT || ' -> ' || DATE_FIN || ' | ' || STATUT FROM RESERVATIONS;"
                        echo "========================================="
                        read -p "Appuyez sur Entrée..."
                        ;;
                    3)
                        echo ""
                        read -p "ID Reservation à annuler: " id
                        read -p "Confirmer (O/N): " conf
                        if [ "$conf" = "O" ] || [ "$conf" = "o" ]; then
                            chambre=$(sqlite3 data/input/hotel.db "SELECT ID_CHAMBRE FROM RESERVATIONS WHERE ID_RESERVATION='$id';")
                            sqlite3 data/input/hotel.db "UPDATE RESERVATIONS SET STATUT='ANNULEE' WHERE ID_RESERVATION='$id';"
                            sqlite3 data/input/hotel.db "UPDATE CHAMBRES SET STATUT='DISPONIBLE' WHERE ID_CHAMBRE='$chambre';"
                            echo "✓ Réservation annulée"
                        else
                            echo "Annulé"
                        fi
                        read -p "Appuyez sur Entrée..."
                        ;;
                    0)
                        break
                        ;;
                esac
            done
            ;;
        4)
            while true; do
                echo ""
                echo "╔════════════════════════════════════════════════════╗"
                echo "║                    RAPPORTS                        ║"
                echo "╠════════════════════════════════════════════════════╣"
                echo "║  1. Rapport occupation                            ║"
                echo "║  2. Rapport chiffre d'affaires                    ║"
                echo "║  0. Retour                                        ║"
                echo "╚════════════════════════════════════════════════════╝"
                read -p "Choix : " sub_choix
                
                case $sub_choix in
                     1)
                        echo ""
                        echo "=== RAPPORT D'OCCUPATION ==="
                        echo ""
                        echo "CHAMBRES OCCUPEES:"
                        sqlite3 data/input/hotel.db "SELECT NUMERO || ' - ' || STATUT FROM CHAMBRES WHERE STATUT != 'DISPONIBLE';"
                        echo ""
                        echo "STATISTIQUES:"
                        total=$(sqlite3 data/input/hotel.db "SELECT COUNT(*) FROM CHAMBRES;")
                        occupees=$(sqlite3 data/input/hotel.db "SELECT COUNT(*) FROM CHAMBRES WHERE STATUT != 'DISPONIBLE';")
                        echo "Taux occupation: $(( occupees * 100 / total ))%"
                        read -p "Appuyez sur Entrée..."
                        ;;
                    2)
                        echo ""
                        echo "=== RAPPORT CHIFFRE D'AFFAIRES ==="
                        echo ""
                        # FIXED: Changed MONTANT to MONTANT_TOTAL
                        ca=$(sqlite3 data/input/hotel.db "SELECT COALESCE(SUM(MONTANT_TOTAL), 0) FROM RESERVATIONS WHERE STATUT='CONFIRMEE';")
                        echo "CA TOTAL: $ca €"
                        read -p "Appuyez sur Entrée..."
                        ;;
                    0)
                        break
                        ;;
                esac
            done
            ;;
        0)
            echo "Merci d'avoir utilisé Hotel Paradise !"
            exit 0
            ;;
    esac
done
