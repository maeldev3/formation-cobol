       IDENTIFICATION DIVISION.
       PROGRAM-ID. RECHERCHE-CREDIT.
       
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
       01 WS-ID            PIC X(6).
       01 WS-FIN           PIC X VALUE 'N'.
       01 WS-TROUVE        PIC X VALUE 'N'.
       01 WS-MONTANT-EDIT  PIC Z(9)9.99.
       01 WS-MENSUALITE-EDIT PIC Z(9)9.99.
       01 WS-RESTANT-EDIT  PIC Z(9)9.99.
       
       PROCEDURE DIVISION.
           DISPLAY "========================================="
           DISPLAY "=== RECHERCHE D'UN CREDIT ==="
           DISPLAY "========================================="
           DISPLAY " "
           DISPLAY "ID CREDIT: "
           ACCEPT WS-ID
           
           OPEN INPUT FICHIER-CREDIT
           MOVE 'N' TO WS-TROUVE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CREDIT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-CREDIT = WS-ID
                           MOVE 'Y' TO WS-TROUVE
                           MOVE MONTANT-CREDIT TO WS-MONTANT-EDIT
                           MOVE MENSUALITE TO WS-MENSUALITE-EDIT
                           MOVE CAPITAL-RESTANT TO WS-RESTANT-EDIT
                           DISPLAY " "
                           DISPLAY "========================================="
                           DISPLAY "=== DETAILS DU CREDIT ==="
                           DISPLAY "========================================="
                           DISPLAY "ID CREDIT      : " ID-CREDIT
                           DISPLAY "COMPTE         : " NUM-COMPTE-CR
                           DISPLAY "MONTANT        : " WS-MONTANT-EDIT " €"
                           DISPLAY "TAUX           : " TAUX-CREDIT " %"
                           DISPLAY "DUREE          : " DUREE-CREDIT " mois"
                           DISPLAY "MENSUALITE     : " WS-MENSUALITE-EDIT " €"
                           DISPLAY "CAPITAL RESTANT: " WS-RESTANT-EDIT " €"
                           DISPLAY "DATE DEBUT     : " DATE-DEBUT
                           DISPLAY "STATUT         : " STATUT-CR
                           DISPLAY "========================================="
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-CREDIT
           
           IF WS-TROUVE = 'N'
               DISPLAY "ERREUR: Credit non trouve"
           END-IF
           
           STOP RUN.
