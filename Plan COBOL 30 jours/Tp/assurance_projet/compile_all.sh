echo "=== COMPILATION DU SYSTEME ASSURANCE ==="
echo ""

mkdir -p bin

echo "Compilation des modules clients..."
cobc -x -free -o bin/AJOUT_CLIENT src/modules/CLIENTS/AJOUT_CLIENT.cob
cobc -x -free -o bin/MODIF_CLIENT src/modules/CLIENTS/MODIF_CLIENT.cob
cobc -x -free -o bin/RECHERCHE_CLIENT src/modules/CLIENTS/RECHERCHE_CLIENT.cob

echo "Compilation des modules contrats..."
cobc -x -free -o bin/CREER_CONTRAT src/modules/CONTRATS/CREER_CONTRAT.cob
cobc -x -free -o bin/RESILIER_CONTRAT src/modules/CONTRATS/RESILIER_CONTRAT.cob
cobc -x -free -o bin/LISTE_CONTRATS src/modules/CONTRATS/LISTE_CONTRATS.cob

echo "Compilation des modules sinistres..."
cobc -x -free -o bin/DECLARER_SINISTRE src/modules/SINISTRES/DECLARER_SINISTRE.cob
cobc -x -free -o bin/TRAITER_SINISTRE src/modules/SINISTRES/TRAITER_SINISTRE.cob
cobc -x -free -o bin/SUIVI_SINISTRE src/modules/SINISTRES/SUIVI_SINISTRE.cob

echo "Compilation des modules paiements..."
cobc -x -free -o bin/INDEMNISER src/modules/PAIEMENTS/INDEMNISER.cob
cobc -x -free -o bin/HISTORIQUE_PAIEMENT src/modules/PAIEMENTS/HISTORIQUE_PAIEMENT.cob

echo "Compilation des batchs..."
cobc -x -free -o bin/BATCH_QUOTIDIEN src/batch/BATCH_QUOTIDIEN.cob
cobc -x -free -o bin/BATCH_HEBDOMADAIRE src/batch/BATCH_HEBDOMADAIRE.cob
cobc -x -free -o bin/BATCH_MENSUEL src/batch/BATCH_MENSUEL.cob

echo "Compilation des rapports..."
cobc -x -free -o bin/RAPPORT_CONTRATS src/reports/RAPPORT_CONTRATS.cob
cobc -x -free -o bin/RAPPORT_SINISTRES src/reports/RAPPORT_SINISTRES.cob
cobc -x -free -o bin/RAPPORT_FINANCIER src/reports/RAPPORT_FINANCIER.cob

echo ""
echo "=== COMPILATION TERMINEE ==="
ls -la bin/
EOF

chmod +x assurance_projet/compile_all.sh
