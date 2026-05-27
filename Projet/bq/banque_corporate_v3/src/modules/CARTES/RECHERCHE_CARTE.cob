       IDENTIFICATION DIVISION.
       PROGRAM-ID. RECHERCHE-CARTE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CARTE ASSIGN TO 'data/input/CARTES.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-CARTE.
       01 ENR-CARTE.
          05 ID-CARTE       PIC X(6).
          05 FILLER         PIC X(1).
          05 NUM-COMPTE-C   PIC X(6).
          05 FILLER         PIC X(1).
          05 ID-CLIENT-CARTE PIC X(6).
          05 FILLER         PIC X(1).
          05 NUMERO-CARTE   PIC X(16).
          05 FILLER         PIC X(1).
          05 DATE-EXP       PIC X(4).
          05 FILLER         PIC X(1).
          05 CVV            PIC X(3).
          05 FILLER         PIC X(1).
          05 DATE-EMISSION  PIC X(10).
          05 FILLER         PIC X(1).
          05 DATE-VALIDITE  PIC X(10).
          05 FILLER         PIC X(1).
          05 STATUT-CARTE   PIC X(6).
          05 FILLER         PIC X(1).
          05 PLAFOND        PIC 9(8)V99.
          05 FILLER         PIC X(1).
          05 TYPE-CARTE     PIC X(15).
       
       WORKING-STORAGE SECTION.
       01 WS-ID            PIC X(6).
       01 WS-FIN           PIC X VALUE 'N'.
       01 WS-TROUVE        PIC X VALUE 'N'.
       01 WS-PLAFOND-EDIT  PIC Z(8)9.99.
       
       PROCEDURE DIVISION.
           DISPLAY "========================================="
           DISPLAY "=== RECHERCHE D'UNE CARTE ==="
           DISPLAY "========================================="
           DISPLAY " "
           DISPLAY "ID CARTE: "
           ACCEPT WS-ID
           
           OPEN INPUT FICHIER-CARTE
           MOVE 'N' TO WS-TROUVE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CARTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-CARTE = WS-ID
                           MOVE 'Y' TO WS-TROUVE
                           MOVE PLAFOND TO WS-PLAFOND-EDIT
                           DISPLAY " "
                           DISPLAY "========================================="
                           DISPLAY "=== DETAILS DE LA CARTE ==="
                           DISPLAY "========================================="
                           DISPLAY "ID CARTE       : " ID-CARTE
                           DISPLAY "NUMERO COMPTE  : " NUM-COMPTE-C
                           DISPLAY "ID CLIENT      : " ID-CLIENT-CARTE
                           DISPLAY "NUMERO CARTE   : " NUMERO-CARTE
                           DISPLAY "TYPE           : " TYPE-CARTE
                           DISPLAY "PLAFOND        : " WS-PLAFOND-EDIT " €"
                           DISPLAY "DATE EMISSION  : " DATE-EMISSION
                           DISPLAY "DATE VALIDITE  : " DATE-VALIDITE
                           DISPLAY "DATE EXP       : " DATE-EXP
                           DISPLAY "CVV            : " CVV
                           DISPLAY "STATUT         : " STATUT-CARTE
                           DISPLAY "========================================="
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-CARTE
           
           IF WS-TROUVE = 'N'
               DISPLAY "ERREUR: Carte non trouvee"
           END-IF
           
           STOP RUN.
