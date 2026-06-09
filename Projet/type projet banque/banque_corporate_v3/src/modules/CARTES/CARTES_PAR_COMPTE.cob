       IDENTIFICATION DIVISION.
       PROGRAM-ID. CARTES-PAR-COMPTE.
       
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
       01 WS-COMPTE        PIC X(6).
       01 WS-FIN           PIC X VALUE 'N'.
       01 WS-COUNT         PIC 9(6) VALUE 0.
       01 WS-PLAFOND-EDIT  PIC Z(8)9.99.
       01 WS-TOTAL-PLAFOND PIC 9(12)V99 VALUE 0.
       
       PROCEDURE DIVISION.
           DISPLAY "========================================="
           DISPLAY "=== CARTES D'UN COMPTE ==="
           DISPLAY "========================================="
           DISPLAY " "
           DISPLAY "NUMERO DE COMPTE: "
           ACCEPT WS-COMPTE
           
           OPEN INPUT FICHIER-CARTE
           MOVE 'N' TO WS-FIN
           MOVE 0 TO WS-COUNT
           MOVE 0 TO WS-TOTAL-PLAFOND
           
           DISPLAY " "
           DISPLAY "ID     TYPE            PLAFOND     STATUT  EXP"
           DISPLAY "------ --------------- ----------- ------ ----"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CARTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF NUM-COMPTE-C = WS-COMPTE
                           ADD 1 TO WS-COUNT
                           ADD PLAFOND TO WS-TOTAL-PLAFOND
                           MOVE PLAFOND TO WS-PLAFOND-EDIT
                           DISPLAY ID-CARTE " "
                                   TYPE-CARTE(1:15) " "
                                   WS-PLAFOND-EDIT " "
                                   STATUT-CARTE " "
                                   DATE-EXP
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-CARTE
           
           DISPLAY " "
           DISPLAY "========================================="
           DISPLAY "Nombre de cartes: " WS-COUNT
           DISPLAY "Plafond total  : " WS-TOTAL-PLAFOND " €"
           DISPLAY "========================================="
           
           IF WS-COUNT = 0
               DISPLAY "Aucune carte associee a ce compte"
           END-IF
           
           STOP RUN.
