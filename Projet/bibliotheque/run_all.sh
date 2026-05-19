#!/bin/bash

clear
echo "========================================="
echo "   BIBLIOTHEQUE MUNICIPALE - SYSTEME"
echo "========================================="

while true; do
    echo ""
    echo "┌─────────────────────────────────────┐"
    echo "│            MENU PRINCIPAL           │"
    echo "├─────────────────────────────────────┤"
    echo "│ 1. Gestion Adhérents                │"
    echo "│ 2. Gestion Livres                   │"
    echo "│ 3. Gestion Emprunts                 │"
    echo "│ 4. Batch Quotidien                  │"
    echo "│ 5. Rapports                         │"
    echo "│ 0. Quitter                          │"
    echo "└─────────────────────────────────────┘"
    echo -n "Choix : "
    read choix

    case $choix in
        1)
            echo ""
            echo "--- GESTION ADHERENTS ---"
            echo "1. Lister adhérents"
            echo "2. Ajouter adhérent"
            echo "3. Rechercher adhérent"
            echo -n "Choix : "
            read sub
            case $sub in
                1) bin/LISTER_ADHERENTS ;;
                2) bin/AJOUT_ADHERENT ;;
                3) bin/RECHERCHE_ADHERENT ;;
                *) echo "Option invalide" ;;
            esac
            ;;
        2)
            echo ""
            echo "--- GESTION LIVRES ---"
            echo "1. Lister livres"
            echo "2. Ajouter livre"
            echo "3. Rechercher livre"
            echo -n "Choix : "
            read sub
            case $sub in
                1) bin/LISTER_LIVRES ;;
                2) bin/AJOUT_LIVRE ;;
                3) bin/RECHERCHE_LIVRE ;;
                *) echo "Option invalide" ;;
            esac
            ;;
        3)
            echo ""
            echo "--- GESTION EMPRUNTS ---"
            echo "1. Emprunter livre"
            echo "2. Retourner livre"
            echo "3. Emprunts en cours"
            echo -n "Choix : "
            read sub
            case $sub in
                1) bin/EMPRUNTER ;;
                2) bin/RETOUR ;;
                3) bin/EMPRUNTS_EN_COURS ;;
                *) echo "Option invalide" ;;
            esac
            ;;
        4)
            echo ""
            echo "--- BATCH QUOTIDIEN ---"
            if [ -f bin/BATCH_AMENDES ]; then
                bin/BATCH_AMENDES
            else
                echo "Module BATCH_AMENDES non disponible"
            fi
            echo "Batch terminé"
            ;;
        5)
            echo ""
            echo "--- RAPPORTS ---"
            echo "1. Rapport adhérents actifs"
            echo "2. Rapport livres populaires"
            echo "3. Rapport retards"
            echo -n "Choix : "
            read sub
            case $sub in
                1) 
                    if [ -f bin/RAPPORT_ADHERENTS_ACTIFS ]; then
                        bin/RAPPORT_ADHERENTS_ACTIFS
                    else
                        echo "Module non disponible"
                    fi
                    ;;
                2)
                    if [ -f bin/RAPPORT_LIVRES_POPULAIRES ]; then
                        bin/RAPPORT_LIVRES_POPULAIRES
                    else
                        echo "Module non disponible"
                    fi
                    ;;
                3)
                    if [ -f bin/RAPPORT_RETARDS ]; then
                        bin/RAPPORT_RETARDS
                    else
                        echo "Module non disponible"
                    fi
                    ;;
                *) echo "Option invalide" ;;
            esac
            ;;
        0)
            echo "Au revoir !"
            exit 0
            ;;
        *)
            echo "Option invalide"
            ;;
    esac
done
