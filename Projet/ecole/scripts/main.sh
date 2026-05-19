#!/bin/bash

cd "$(dirname "$0")/.."

show_menu() {
    clear
    echo "========================================="
    echo "   GESTION ECOLE v1.0"
    echo "   $(date '+%d/%m/%Y %H:%M')"
    echo "========================================="
    echo ""
    echo "┌─────────────────────────────────────────────┐"
    echo "│                 MENU PRINCIPAL              │"
    echo "├─────────────────────────────────────────────┤"
    echo "│ 1. Gestion Etudiants                       │"
    echo "│ 2. Gestion Notes                           │"
    echo "│ 3. Bulletin Scolaire                       │"
    echo "│ 4. Batch Quotidien                         │"
    echo "│ 5. Rapports                                │"
    echo "│ 6. SQL (simulé)                            │"
    echo "│ 7. Statistiques                            │"
    echo "│ 0. Quitter                                 │"
    echo "└─────────────────────────────────────────────┘"
    echo -n "Choix : "
}

menu_etudiants() {
    while true; do
        clear
        echo "--- GESTION ETUDIANTS ---"
        echo "1. Lister etudiants"
        echo "2. Ajouter etudiant"
        echo "3. Rechercher etudiant"
        echo "0. Retour"
        echo -n "Choix : "
        read sub
        case $sub in
            1) bin/LISTER_ETUDIANTS ;;
            2) 
                read -p "ID (E00011): " id
                read -p "NOM: " nom
                read -p "PRENOM: " prenom
                read -p "DATE NAISS (DD/MM/YYYY): " date
                read -p "CLASSE (3A/3B/4A/4B): " classe
                echo -e "$id\n$nom\n$prenom\n$date\n$classe" | bin/AJOUT_ETUDIANT
                ;;
            3)
                read -p "ID: " id
                echo "$id" | bin/RECHERCHE_ETUDIANT
                ;;
            0) break ;;
        esac
        read -p "Appuyez sur Entrée..."
    done
}

menu_notes() {
    while true; do
        clear
        echo "--- GESTION NOTES ---"
        echo "1. Lister toutes les notes"
        echo "2. Ajouter une note"
        echo "0. Retour"
        echo -n "Choix : "
        read sub
        case $sub in
            1) bin/LISTER_NOTES ;;
            2)
                read -p "ID ETUDIANT: " etu
                read -p "ID COURS: " cours
                read -p "NOTE (0-20): " note
                echo -e "$etu\n$cours\n$note" | bin/AJOUT_NOTE
                ;;
            0) break ;;
        esac
        read -p "Appuyez sur Entrée..."
    done
}

run_batch() {
    clear
    echo "--- BATCH QUOTIDIEN ---"
    bin/BATCH_ECOLE
    read -p "Appuyez sur Entrée..."
}

show_reports() {
    clear
    echo "=== RAPPORTS ==="
    echo "1. Rapport batch"
    echo "2. Bulletin individuel"
    echo "3. Liste des etudiants"
    echo "4. Liste des notes"
    echo -n "Choix : "
    read sub
    case $sub in
        1) cat data/output/reports/RAPPORT_ECOLE.rpt 2>/dev/null || echo "Aucun rapport" ;;
        2)
            read -p "ID ETUDIANT: " id
            echo "$id" | bin/BULLETIN_ETUDIANT
            cat data/output/reports/BULLETIN.rpt
            ;;
        3) bin/LISTER_ETUDIANTS ;;
        4) bin/LISTER_NOTES ;;
    esac
    read -p "Appuyez sur Entrée..."
}

show_sql() {
    clear
    echo "=== MODE SQL (Simulé) ==="
    echo "1. Afficher tous les etudiants"
    echo "2. Afficher tous les cours"
    echo "3. Moyenne par etudiant"
    echo "4. Meilleurs etudiants (moyenne > 15)"
    echo "5. Distribution des mentions"
    echo "0. Retour"
    echo -n "Choix : "
    read sub
    case $sub in
        1) 
            echo "=== ETUDIANTS ==="
            cat data/input/ETUDIANTS.DAT
            ;;
        2)
            echo "=== COURS ==="
            cat data/input/COURS.DAT
            ;;
        3)
            echo "=== MOYENNES PAR ETUDIANT ==="
            echo "À partir des fichiers..."
            ;;
        4)
            echo "=== MEILLEURS ETUDIANTS ==="
            ;;
        5)
            echo "=== DISTRIBUTION MENTIONS ==="
            cat data/input/EVALUATIONS.DAT 2>/dev/null || echo "Aucune evaluation"
            ;;
    esac
    read -p "Appuyez sur Entrée..."
}

show_stats() {
    clear
    echo "=== STATISTIQUES ECOLE ==="
    echo ""
    echo "Etudiants: $(wc -l < data/input/ETUDIANTS.DAT 2>/dev/null || echo 0)"
    echo "Cours: $(wc -l < data/input/COURS.DAT 2>/dev/null || echo 0)"
    echo "Notes: $(wc -l < data/input/NOTES.DAT 2>/dev/null || echo 0)"
    echo "Evaluations: $(wc -l < data/input/EVALUATIONS.DAT 2>/dev/null || echo 0)"
    read -p "Appuyez sur Entrée..."
}

while true; do
    show_menu
    read choix
    case $choix in
        1) menu_etudiants ;;
        2) menu_notes ;;
        3) 
            read -p "ID ETUDIANT: " id
            echo "$id" | bin/BULLETIN_ETUDIANT
            cat data/output/reports/BULLETIN.rpt
            read -p "Appuyez sur Entrée..."
            ;;
        4) run_batch ;;
        5) show_reports ;;
        6) show_sql ;;
        7) show_stats ;;
        0) echo "Au revoir !"; exit 0 ;;
    esac
done
