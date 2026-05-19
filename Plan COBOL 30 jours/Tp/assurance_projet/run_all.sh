cat > assurance_projet/run_all.sh << 'EOF'
#!/bin/bash

echo "=== SYSTEME ASSURANCE - EXECUTION ==="
echo ""

# Menu principal
while true; do
    echo ""
    echo "1 - Gestion clients"
    echo "2 - Gestion contrats"
    echo "3 - Gestion sinistres"
    echo "4 - Gestion paiements"
    echo "5 - Batch quotidien"
    echo "6 - Rapports"
    echo "0 - Quitter"
    echo -n "Choix: "
    read choix

    case $choix in
        1)
            echo "--- GESTION CLIENTS ---"
            echo "1 - Ajouter client"
            echo "2 - Modifier client"
            echo "3 - Rechercher client"
            read sub
            case $sub in
                1) bin/AJOUT_CLIENT ;;
                2) bin/MODIF_CLIENT ;;
                3) bin/RECHERCHE_CLIENT ;;
            esac
            ;;
        2)
            echo "--- GESTION CONTRATS ---"
            echo "1 - Créer contrat"
            echo "2 - Résilier contrat"
            echo "3 - Lister contrats"
            read sub
            case $sub in
                1) bin/CREER_CONTRAT ;;
                2) bin/RESILIER_CONTRAT ;;
                3) bin/LISTE_CONTRATS ;;
            esac
            ;;
        3)
            echo "--- GESTION SINISTRES ---"
            echo "1 - Déclarer sinistre"
            echo "2 - Traiter sinistre"
            echo "3 - Suivi sinistre"
            read sub
            case $sub in
                1) bin/DECLARER_SINISTRE ;;
                2) bin/TRAITER_SINISTRE ;;
                3) bin/SUIVI_SINISTRE ;;
            esac
            ;;
        4)
            echo "--- GESTION PAIEMENTS ---"
            echo "1 - Indemniser"
            echo "2 - Historique paiements"
            read sub
            case $sub in
                1) bin/INDEMNISER ;;
                2) bin/HISTORIQUE_PAIEMENT ;;
            esac
            ;;
        5)
            echo "--- BATCH QUOTIDIEN ---"
            bin/BATCH_QUOTIDIEN
            ;;
        6)
            echo "--- RAPPORTS ---"
            echo "1 - Rapport contrats"
            echo "2 - Rapport sinistres"
            echo "3 - Rapport financier"
            read sub
            case $sub in
                1) bin/RAPPORT_CONTRATS ;;
                2) bin/RAPPORT_SINISTRES ;;
                3) bin/RAPPORT_FINANCIER ;;
            esac
            ;;
        0)
            echo "Au revoir!"
            exit 0
            ;;
    esac
done
EOF

chmod +x assurance_projet/run_all.sh
