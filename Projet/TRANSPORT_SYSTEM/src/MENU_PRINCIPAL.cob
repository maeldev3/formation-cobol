       IDENTIFICATION DIVISION.
       PROGRAM-ID. MENU-PRINCIPAL.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-CHOIX         PIC 9.
       01 WS-SOUS-CHOIX    PIC 9.
       01 WS-QUITTER       PIC X VALUE 'N'.
           88 WS-QUITTER-OUI VALUE 'O'.
       
       01 WS-DATE-SYSTEME.
           05 WS-ANNEE     PIC 9(4).
           05 WS-MOIS      PIC 9(2).
           05 WS-JOUR      PIC 9(2).
       
       PROCEDURE DIVISION.
       
       MAIN-PROCEDURE.
           MOVE FUNCTION CURRENT-DATE(1:4) TO WS-ANNEE
           MOVE FUNCTION CURRENT-DATE(6:2) TO WS-MOIS
           MOVE FUNCTION CURRENT-DATE(9:2) TO WS-JOUR
           
           PERFORM UNTIL WS-QUITTER-OUI
               DISPLAY " "
               DISPLAY "╔══════════════════════════════════════════════════════════════╗"
               DISPLAY "║              SYSTEME DE GESTION DE TRANSPORT                ║"
               DISPLAY "╠══════════════════════════════════════════════════════════════╣"
               DISPLAY "║  Date: " WS-JOUR "/" WS-MOIS "/" WS-ANNEE "                                     ║"
               DISPLAY "╠══════════════════════════════════════════════════════════════╣"
               DISPLAY "║  1. GESTION DES BUS                                          ║"
               DISPLAY "║  2. GESTION DES CONDUCTEURS                                  ║"
               DISPLAY "║  3. GESTION DES TRAJETS                                      ║"
               DISPLAY "║  4. RAPPORTS                                                 ║"
               DISPLAY "║  5. SAUVEGARDE / EXPORT                                      ║"
               DISPLAY "║  0. QUITTER                                                  ║"
               DISPLAY "╚══════════════════════════════════════════════════════════════╝"
               DISPLAY "Choix : " WITH NO ADVANCING
               ACCEPT WS-CHOIX
               
               EVALUATE WS-CHOIX
                   WHEN 1 PERFORM MENU-BUS
                   WHEN 2 PERFORM MENU-CONDUCTEURS
                   WHEN 3 PERFORM MENU-TRAJETS
                   WHEN 4 PERFORM MENU-RAPPORTS
                   WHEN 5 PERFORM MENU-EXPORT
                   WHEN 0 MOVE 'O' TO WS-QUITTER
                   WHEN OTHER DISPLAY "Choix invalide"
               END-EVALUATE
           END-PERFORM
           
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║         MERCI D'AVOIR UTILISE NOTRE SYSTEME        ║"
           DISPLAY "║                  A BIENTOT !                       ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
       
       MENU-BUS.
           PERFORM UNTIL WS-QUITTER-OUI
               DISPLAY " "
               DISPLAY "╔════════════════════════════════════════════════════╗"
               DISPLAY "║                 GESTION DES BUS                    ║"
               DISPLAY "╠════════════════════════════════════════════════════╣"
               DISPLAY "║  1. CREER     - Ajouter un bus                     ║"
               DISPLAY "║  2. LISTER    - Afficher tous les bus              ║"
               DISPLAY "║  3. MODIFIER  - Modifier un bus                    ║"
               DISPLAY "║  4. SUPPRIMER - Supprimer un bus                   ║"
               DISPLAY "║  0. RETOUR                                         ║"
               DISPLAY "╚════════════════════════════════════════════════════╝"
               DISPLAY "Choix : " WITH NO ADVANCING
               ACCEPT WS-SOUS-CHOIX
               
               EVALUATE WS-SOUS-CHOIX
                   WHEN 1 CALL "./bin/CREER_BUS"
                   WHEN 2 CALL "./bin/LISTER_BUS"
                   WHEN 3 CALL "./bin/MODIFIER_BUS"
                   WHEN 4 CALL "./bin/SUPPRIMER_BUS"
                   WHEN 0 EXIT PERFORM
                   WHEN OTHER DISPLAY "Choix invalide"
               END-EVALUATE
           END-PERFORM.
       
       MENU-CONDUCTEURS.
           PERFORM UNTIL WS-QUITTER-OUI
               DISPLAY " "
               DISPLAY "╔════════════════════════════════════════════════════╗"
               DISPLAY "║              GESTION DES CONDUCTEURS               ║"
               DISPLAY "╠════════════════════════════════════════════════════╣"
               DISPLAY "║  1. CREER     - Ajouter un conducteur              ║"
               DISPLAY "║  2. LISTER    - Afficher tous les conducteurs      ║"
               DISPLAY "║  3. MODIFIER  - Modifier un conducteur             ║"
               DISPLAY "║  4. SUPPRIMER - Supprimer un conducteur            ║"
               DISPLAY "║  0. RETOUR                                         ║"
               DISPLAY "╚════════════════════════════════════════════════════╝"
               DISPLAY "Choix : " WITH NO ADVANCING
               ACCEPT WS-SOUS-CHOIX
               
               EVALUATE WS-SOUS-CHOIX
                   WHEN 1 CALL "./bin/CREER_CONDUCTEUR"
                   WHEN 2 CALL "./bin/LISTER_CONDUCTEURS"
                   WHEN 3 CALL "./bin/MODIFIER_CONDUCTEUR"
                   WHEN 4 CALL "./bin/SUPPRIMER_CONDUCTEUR"
                   WHEN 0 EXIT PERFORM
                   WHEN OTHER DISPLAY "Choix invalide"
               END-EVALUATE
           END-PERFORM.
       
       MENU-TRAJETS.
           PERFORM UNTIL WS-QUITTER-OUI
               DISPLAY " "
               DISPLAY "╔════════════════════════════════════════════════════╗"
               DISPLAY "║               GESTION DES TRAJETS                  ║"
               DISPLAY "╠════════════════════════════════════════════════════╣"
               DISPLAY "║  1. CREER     - Ajouter un trajet                  ║"
               DISPLAY "║  2. LISTER    - Afficher tous les trajets          ║"
               DISPLAY "║  3. MODIFIER  - Modifier un trajet                 ║"
               DISPLAY "║  4. ANNULER   - Annuler un trajet                  ║"
               DISPLAY "║  0. RETOUR                                         ║"
               DISPLAY "╚════════════════════════════════════════════════════╝"
               DISPLAY "Choix : " WITH NO ADVANCING
               ACCEPT WS-SOUS-CHOIX
               
               EVALUATE WS-SOUS-CHOIX
                   WHEN 1 CALL "./bin/CREER_TRAJET"
                   WHEN 2 CALL "./bin/LISTER_TRAJETS"
                   WHEN 3 CALL "./bin/MODIFIER_TRAJET"
                   WHEN 4 CALL "./bin/ANNULER_TRAJET"
                   WHEN 0 EXIT PERFORM
                   WHEN OTHER DISPLAY "Choix invalide"
               END-EVALUATE
           END-PERFORM.
       
       MENU-RAPPORTS.
           PERFORM UNTIL WS-QUITTER-OUI
               DISPLAY " "
               DISPLAY "╔════════════════════════════════════════════════════╗"
               DISPLAY "║                    RAPPORTS                        ║"
               DISPLAY "╠════════════════════════════════════════════════════╣"
               DISPLAY "║  1. Rapport occupation des bus                    ║"
               DISPLAY "║  2. Rapport chiffre d'affaires                    ║"
               DISPLAY "║  0. RETOUR                                         ║"
               DISPLAY "╚════════════════════════════════════════════════════╝"
               DISPLAY "Choix : " WITH NO ADVANCING
               ACCEPT WS-SOUS-CHOIX
               
               EVALUATE WS-SOUS-CHOIX
                   WHEN 1 CALL "./bin/RAPPORT_OCCUPATION"
                   WHEN 2 CALL "./bin/RAPPORT_CA"
                   WHEN 0 EXIT PERFORM
                   WHEN OTHER DISPLAY "Choix invalide"
               END-EVALUATE
           END-PERFORM.
       
       MENU-EXPORT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║              SAUVEGARDE / EXPORT                   ║"
           DISPLAY "╠════════════════════════════════════════════════════╣"
           DISPLAY "║  1. Exporter les bus vers CSV                      ║"
           DISPLAY "║  2. Exporter les conducteurs vers CSV              ║"
           DISPLAY "║  3. Exporter les trajets vers CSV                  ║"
           DISPLAY "║  4. Sauvegarde complete                            ║"
           DISPLAY "║  0. RETOUR                                         ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "Choix : " WITH NO ADVANCING
           ACCEPT WS-SOUS-CHOIX
           
           EVALUATE WS-SOUS-CHOIX
               WHEN 1 CALL "./bin/EXPORT_BUS_CSV"
               WHEN 2 CALL "./bin/EXPORT_CONDUCTEURS_CSV"
               WHEN 3 CALL "./bin/EXPORT_TRAJETS_CSV"
               WHEN 4 CALL "./bin/BACKUP_DB"
           END-EVALUATE.
