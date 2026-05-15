       IDENTIFICATION DIVISION.
       PROGRAM-ID. BANQUE.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-SOLDE         PIC 9(8)V99 VALUE 1000.00.
       01 WS-MONTANT       PIC 9(8)V99.
       01 WS-CHOIX         PIC 9.

       01 WS-I             PIC 9(2).

       01 WS-HISTORIQUE.
           05 WS-HIST OCCURS 10 TIMES.
               10 WS-TYPE  PIC X(10).
               10 WS-MONT  PIC 9(8)V99.

       01 WS-COMPTEUR      PIC 9(2) VALUE 0.

       PROCEDURE DIVISION.

           PERFORM UNTIL WS-CHOIX = 5
               PERFORM 2000-MENU
               PERFORM 3000-TRAITER
           END-PERFORM

           PERFORM 9000-FERMER
           STOP RUN.

       2000-MENU.
           DISPLAY " "
           DISPLAY "--- MENU PRINCIPAL ---"
           DISPLAY "1. Consulter solde"
           DISPLAY "2. Deposer argent"
           DISPLAY "3. Retirer argent"
           DISPLAY "4. Historique"
           DISPLAY "5. Quitter"
           DISPLAY "Votre choix: "
           ACCEPT WS-CHOIX
           .

       3000-TRAITER.
           EVALUATE WS-CHOIX
               WHEN 1
                   PERFORM 3100-CONSULTER
               WHEN 2
                   PERFORM 3200-DEPOSER
               WHEN 3
                   PERFORM 3300-RETIRER
               WHEN 4
                   PERFORM 3400-HISTORIQUE
               WHEN 5
                   DISPLAY "Au revoir!"
               WHEN OTHER
                   DISPLAY "Option invalide!"
           END-EVALUATE
           .

       3100-CONSULTER.
           DISPLAY "Solde actuel: " WS-SOLDE " EUR"
           .

       3200-DEPOSER.
           DISPLAY "Montant a deposer: "
           ACCEPT WS-MONTANT

           IF WS-MONTANT > 0
               ADD WS-MONTANT TO WS-SOLDE
               ADD 1 TO WS-COMPTEUR

               MOVE "DEPOT" TO WS-TYPE(WS-COMPTEUR)
               MOVE WS-MONTANT TO WS-MONT(WS-COMPTEUR)

               DISPLAY "Depot effectue"
           ELSE
               DISPLAY "Montant invalide"
           END-IF
           .

       3300-RETIRER.
           DISPLAY "Montant a retirer: "
           ACCEPT WS-MONTANT

           IF WS-MONTANT > 0 AND WS-MONTANT <= WS-SOLDE
               SUBTRACT WS-MONTANT FROM WS-SOLDE
               ADD 1 TO WS-COMPTEUR

               MOVE "RETRAIT" TO WS-TYPE(WS-COMPTEUR)
               MOVE WS-MONTANT TO WS-MONT(WS-COMPTEUR)

               DISPLAY "Retrait effectue"
           ELSE
               DISPLAY "Operation invalide"
           END-IF
           .

       3400-HISTORIQUE.
           DISPLAY "=== HISTORIQUE ==="

           IF WS-COMPTEUR = 0
               DISPLAY "Aucune operation"
           ELSE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > WS-COMPTEUR
                   DISPLAY WS-TYPE(WS-I) " : " WS-MONT(WS-I)
               END-PERFORM
           END-IF
           .

       9000-FERMER.
           DISPLAY "Merci d'avoir utilise notre service!"
           .
