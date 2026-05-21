       IDENTIFICATION DIVISION.
       PROGRAM-ID. MENU-PRINCIPAL.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-CHOIX         PIC 9.
       01 WS-QUITTER       PIC X VALUE 'N'.
       
       PROCEDURE DIVISION.
       DEBUT.
           PERFORM UNTIL WS-QUITTER = 'O'
               DISPLAY " "
               DISPLAY "╔══════════════════════════════════════════════════════════════╗"
               DISPLAY "║                    HOTEL PARADISE                            ║"
               DISPLAY "║              SYSTEME COMPLET DE GESTION                      ║"
               DISPLAY "╠══════════════════════════════════════════════════════════════╣"
               DISPLAY "║  1. GESTION CLIENTS (CRUD)                                   ║"
               DISPLAY "║  2. GESTION CHAMBRES (CRUD)                                  ║"
               DISPLAY "║  3. GESTION RESERVATIONS (CRUD)                              ║"
               DISPLAY "║  4. RAPPORTS                                                 ║"
               DISPLAY "║  0. QUITTER                                                  ║"
               DISPLAY "╚══════════════════════════════════════════════════════════════╝"
               DISPLAY "Choix : " WITH NO ADVANCING
               ACCEPT WS-CHOIX
               
               EVALUATE WS-CHOIX
                   WHEN 1 PERFORM GESTION-CLIENTS
                   WHEN 2 PERFORM GESTION-CHAMBRES
                   WHEN 3 PERFORM GESTION-RESERVATIONS
                   WHEN 4 PERFORM GESTION-RAPPORTS
                   WHEN 0 MOVE 'O' TO WS-QUITTER
                   WHEN OTHER DISPLAY "Choix invalide"
               END-EVALUATE
           END-PERFORM.
       
       GESTION-CLIENTS.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║               GESTION CLIENTS (CRUD)               ║"
           DISPLAY "╠════════════════════════════════════════════════════╣"
           DISPLAY "║  1. CREER   - Ajouter un client                    ║"
           DISPLAY "║  2. LIRE    - Lister les clients                   ║"
           DISPLAY "║  3. LIRE    - Rechercher un client                 ║"
           DISPLAY "║  4. MODIFIER- Modifier un client                   ║"
           DISPLAY "║  5. SUPPRIMER- Supprimer un client                 ║"
           DISPLAY "║  0. Retour                                         ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "Choix : " WITH NO ADVANCING
           ACCEPT WS-CHOIX
           EVALUATE WS-CHOIX
               WHEN 1 CALL "./bin/CREER_CLIENT"
               WHEN 2 CALL "./bin/LISTER_CLIENTS"
               WHEN 3 CALL "./bin/RECHERCHER_CLIENT"
               WHEN 4 CALL "./bin/MODIFIER_CLIENT"
               WHEN 5 CALL "./bin/SUPPRIMER_CLIENT"
           END-EVALUATE.
       
       GESTION-CHAMBRES.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║               GESTION CHAMBRES (CRUD)              ║"
           DISPLAY "╠════════════════════════════════════════════════════╣"
           DISPLAY "║  1. CREER   - Ajouter une chambre                  ║"
           DISPLAY "║  2. LIRE    - Lister les chambres                  ║"
           DISPLAY "║  3. MODIFIER- Modifier statut chambre              ║"
           DISPLAY "║  0. Retour                                         ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "Choix : " WITH NO ADVANCING
           ACCEPT WS-CHOIX
           EVALUATE WS-CHOIX
               WHEN 1 CALL "./bin/CREER_CHAMBRE"
               WHEN 2 CALL "./bin/LISTER_CHAMBRES"
               WHEN 3 CALL "./bin/MODIFIER_CHAMBRE"
           END-EVALUATE.
       
       GESTION-RESERVATIONS.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║             GESTION RESERVATIONS (CRUD)            ║"
           DISPLAY "╠════════════════════════════════════════════════════╣"
           DISPLAY "║  1. CREER   - Creer une reservation                ║"
           DISPLAY "║  2. LIRE    - Lister les reservations              ║"
           DISPLAY "║  3. MODIFIER- Annuler une reservation              ║"
           DISPLAY "║  0. Retour                                         ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "Choix : " WITH NO ADVANCING
           ACCEPT WS-CHOIX
           EVALUATE WS-CHOIX
               WHEN 1 CALL "./bin/CREER_RESERVATION"
               WHEN 2 CALL "./bin/LISTER_RESERVATIONS"
               WHEN 3 CALL "./bin/ANNULER_RESERVATION"
           END-EVALUATE.
       
       GESTION-RAPPORTS.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║                    RAPPORTS                        ║"
           DISPLAY "╠════════════════════════════════════════════════════╣"
           DISPLAY "║  1. Rapport occupation                            ║"
           DISPLAY "║  2. Rapport chiffre d'affaires                    ║"
           DISPLAY "║  0. Retour                                        ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "Choix : " WITH NO ADVANCING
           ACCEPT WS-CHOIX
           EVALUATE WS-CHOIX
               WHEN 1 CALL "./bin/RAPPORT_OCCUPATION"
               WHEN 2 CALL "./bin/RAPPORT_CA"
           END-EVALUATE.
       
       STOP RUN.
