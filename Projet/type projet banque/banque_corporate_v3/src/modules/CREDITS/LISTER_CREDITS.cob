       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-CREDITS.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CREDIT ASSIGN TO 'data/input/CREDITS.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-CREDIT.
       01 ENR-CREDIT.
          05 ID-CREDIT      PIC X(6).
          05 FILLER         PIC X(1).
          05 NUM-COMPTE-CR  PIC X(6).
          05 FILLER         PIC X(1).
          05 MONTANT-CREDIT PIC 9(10)V99.
          05 FILLER         PIC X(1).
          05 TAUX-CREDIT    PIC 9(4)V99.
          05 FILLER         PIC X(1).
          05 DUREE-CREDIT   PIC 9(5).
          05 FILLER         PIC X(1).
          05 MENSUALITE     PIC 9(10)V99.
          05 FILLER         PIC X(1).
          05 DATE-DEBUT     PIC X(10).
          05 FILLER         PIC X(1).
          05 STATUT-CR      PIC X(5).
          05 FILLER         PIC X(1).
          05 CAPITAL-RESTANT PIC 9(10)V99.
       
       WORKING-STORAGE SECTION.
       01 WS-FIN           PIC X VALUE 'N'.
       01 WS-COUNT         PIC 9(6) VALUE 0.
       01 WS-TOTAL-MONTANT PIC 9(15)V99 VALUE 0.
       01 WS-MONTANT-EDIT  PIC Z(9)9.99.
       01 WS-MENSUALITE-EDIT PIC Z(9)9.99.
       01 WS-RESTANT-EDIT  PIC Z(9)9.99.
       01 WS-TOTAL-EDIT    PIC Z(9)9.99.
       
       PROCEDURE DIVISION.
           DISPLAY "========================================="
           DISPLAY "=== LISTE DES CREDITS ==="
           DISPLAY "========================================="
           DISPLAY " "
           
           OPEN INPUT FICHIER-CREDIT
           MOVE 'N' TO WS-FIN
           MOVE 0 TO WS-COUNT
           MOVE 0 TO WS-TOTAL-MONTANT
           
           DISPLAY "ID     COMPTE  MONTANT      TAUX  DUREE MENSUALITE  CAP.RESTANT STATUT"
           DISPLAY "------ ------ ------------ ----  ----- ----------- ----------- ------"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CREDIT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COUNT
                       ADD MONTANT-CREDIT TO WS-TOTAL-MONTANT
                       MOVE MONTANT-CREDIT TO WS-MONTANT-EDIT
                       MOVE MENSUALITE TO WS-MENSUALITE-EDIT
                       MOVE CAPITAL-RESTANT TO WS-RESTANT-EDIT
                       DISPLAY ID-CREDIT " "
                               NUM-COMPTE-CR " "
                               WS-MONTANT-EDIT " "
                               TAUX-CREDIT "   "
                               DUREE-CREDIT "    "
                               WS-MENSUALITE-EDIT " "
                               WS-RESTANT-EDIT " "
                               STATUT-CR
               END-READ
           END-PERFORM
           CLOSE FICHIER-CREDIT
           
           DISPLAY " "
           DISPLAY "========================================="
           DISPLAY "Total credits: " WS-COUNT
           MOVE WS-TOTAL-MONTANT TO WS-TOTAL-EDIT
           DISPLAY "Total emprunte: " WS-TOTAL-EDIT " €"
           DISPLAY "========================================="
           
           STOP RUN.
