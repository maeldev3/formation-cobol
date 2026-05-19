       IDENTIFICATION DIVISION.
       PROGRAM-ID. MENU-ADHERENT.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-CHOIX          PIC 9.
       01 WS-QUITTER        PIC X VALUE 'N'.
          88 WS-QUIT        VALUE 'Y'.
       
       PROCEDURE DIVISION.
           PERFORM UNTIL WS-QUIT
               DISPLAY " "
               DISPLAY "=== GESTION ADHERENTS ==="
               DISPLAY "1 - Lister adhérents"
               DISPLAY "2 - Ajouter adhérent"
               DISPLAY "3 - Rechercher adhérent"
               DISPLAY "4 - Modifier adhérent"
               DISPLAY "0 - Retour menu principal"
               DISPLAY " "
               DISPLAY "Votre choix : "
               ACCEPT WS-CHOIX
               
               EVALUATE WS-CHOIX
                   WHEN 1
                       DISPLAY "Liste des adhérents..."
                       CALL 'LISTER_ADHERENTS'
                   WHEN 2
                       CALL 'AJOUT_ADHERENT'
                   WHEN 3
                       CALL 'RECHERCHE_ADHERENT'
                   WHEN 4
                       CALL 'MODIF_ADHERENT'
                   WHEN 0
                       SET WS-QUIT TO TRUE
                   WHEN OTHER
                       DISPLAY "Choix invalide"
               END-EVALUATE
           END-PERFORM.
           
           STOP RUN.
