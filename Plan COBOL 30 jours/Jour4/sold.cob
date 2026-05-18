       IDENTIFICATION DIVISION.
       PROGRAM-ID. BANKMENU.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-CHOIX   PIC 9 VALUE 0.
       01 WS-SOLDE   PIC 9(7)V99 VALUE 100000.
       01 WS-MONTANT PIC 9(7)V99.

       PROCEDURE DIVISION.

       000-MAIN.

           PERFORM UNTIL WS-CHOIX = 4

               DISPLAY "===================="
               DISPLAY "1 CONSULT"
               DISPLAY "2 DEPOT"
               DISPLAY "3 RETRAIT"
               DISPLAY "4 QUITTER"

               ACCEPT WS-CHOIX

               EVALUATE WS-CHOIX
                   WHEN 1
                       PERFORM 100-CONSULT

                   WHEN 2
                       PERFORM 200-DEPOT

                   WHEN 3
                       PERFORM 300-RETRAIT

                   WHEN 4
                       DISPLAY "FIN"

                   WHEN OTHER
                       DISPLAY "INVALIDE"
               END-EVALUATE

           END-PERFORM

           STOP RUN.

       100-CONSULT.
           DISPLAY "SOLDE : " WS-SOLDE.

       200-DEPOT.
           DISPLAY "MONTANT : "
           ACCEPT WS-MONTANT
           ADD WS-MONTANT TO WS-SOLDE
           DISPLAY "DEPOT OK".

       300-RETRAIT.
           DISPLAY "MONTANT : "
           ACCEPT WS-MONTANT

           IF WS-MONTANT <= WS-SOLDE
               SUBTRACT WS-MONTANT FROM WS-SOLDE
               DISPLAY "RETRAIT OK"
           ELSE
               DISPLAY "SOLDE INSUFFISANT"
           END-IF.