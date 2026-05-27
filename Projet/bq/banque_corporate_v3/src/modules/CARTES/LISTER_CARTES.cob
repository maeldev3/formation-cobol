       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-CARTES.
       
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
       01 WS-FIN           PIC X VALUE 'N'.
       01 WS-COUNT         PIC 9(6) VALUE 0.
       01 WS-PLAFOND-EDIT  PIC Z(8)9.99.
       01 WS-ACTIF-COUNT   PIC 9(6) VALUE 0.
       01 WS-BLOQUE-COUNT  PIC 9(6) VALUE 0.
       01 WS-EXPIRE-COUNT  PIC 9(6) VALUE 0.
       01 WS-DATE-COURANTE PIC X(4).
       
       PROCEDURE DIVISION.
           DISPLAY "========================================="
           DISPLAY "=== LISTE DES CARTES BANCAIRES ==="
           DISPLAY "========================================="
           DISPLAY " "
           
           ACCEPT WS-DATE-COURANTE FROM DATE
           MOVE WS-DATE-COURANTE(1:4) TO WS-DATE-COURANTE
           
           OPEN INPUT FICHIER-CARTE
           MOVE 'N' TO WS-FIN
           MOVE 0 TO WS-COUNT
           MOVE 0 TO WS-ACTIF-COUNT
           MOVE 0 TO WS-BLOQUE-COUNT
           MOVE 0 TO WS-EXPIRE-COUNT
           
           DISPLAY "ID     COMPTE  CLIENT  TYPE            PLAFOND     STATUT  EXP"
           DISPLAY "------ ------ ------ ---------------  ----------- ------ ----"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CARTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COUNT
                       MOVE PLAFOND TO WS-PLAFOND-EDIT
                       
                       IF STATUT-CARTE = "ACTIF"
                           ADD 1 TO WS-ACTIF-COUNT
                       ELSE
                           IF STATUT-CARTE = "BLOQUE"
                               ADD 1 TO WS-BLOQUE-COUNT
                           ELSE
                               ADD 1 TO WS-EXPIRE-COUNT
                           END-IF
                       END-IF
                       
                       DISPLAY ID-CARTE " "
                               NUM-COMPTE-C " "
                               ID-CLIENT-CARTE " "
                               TYPE-CARTE(1:15) " "
                               WS-PLAFOND-EDIT " "
                               STATUT-CARTE " "
                               DATE-EXP
               END-READ
           END-PERFORM
           CLOSE FICHIER-CARTE
           
           DISPLAY " "
           DISPLAY "========================================="
           DISPLAY "=== STATISTIQUES DES CARTES ==="
           DISPLAY "========================================="
           DISPLAY "Total cartes      : " WS-COUNT
           DISPLAY "Cartes actives    : " WS-ACTIF-COUNT
           DISPLAY "Cartes bloquees   : " WS-BLOQUE-COUNT
           DISPLAY "Cartes expirees   : " WS-EXPIRE-COUNT
           DISPLAY "========================================="
           
           STOP RUN.
