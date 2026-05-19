       IDENTIFICATION DIVISION.
       PROGRAM-ID. HISTORIQUE-TRANSACTIONS.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-TRANSACTION ASSIGN TO 'data/input/TRANSACTIONS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-TRANSACTION.
       01 ENR-TRANS.
          05 ID-TRANS        PIC X(6).
          05 FILLER          PIC X(1).
          05 NUM-COMPTE-T    PIC X(6).
          05 FILLER          PIC X(1).
          05 DATE-TRANS      PIC X(10).
          05 FILLER          PIC X(1).
          05 MONTANT-TRANS   PIC 9(8)V99.
          05 FILLER          PIC X(1).
          05 TYPE-TRANS      PIC X(7).
       
       WORKING-STORAGE SECTION.
       01 WS-NUM-COMPTE      PIC X(6).
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-COMPTEUR        PIC 99 VALUE 0.
       01 WS-TOTAL           PIC 9(9)V99 VALUE 0.
       
       PROCEDURE DIVISION.
           DISPLAY "=== HISTORIQUE DES TRANSACTIONS ==="
           DISPLAY " "
           DISPLAY "NUMERO DE COMPTE: "
           ACCEPT WS-NUM-COMPTE
           
           OPEN INPUT FICHIER-TRANSACTION
           
           DISPLAY " "
           DISPLAY "ID     DATE       TYPE     MONTANT"
           DISPLAY "------------------------------------"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-TRANSACTION
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF NUM-COMPTE-T = WS-NUM-COMPTE
                           ADD 1 TO WS-COMPTEUR
                           ADD MONTANT-TRANS TO WS-TOTAL
                           DISPLAY ID-TRANS " " DATE-TRANS "   "
                                   TYPE-TRANS "   " MONTANT-TRANS " €"
                       END-IF
               END-READ
           END-PERFORM
           
           DISPLAY "------------------------------------"
           DISPLAY "TOTAL TRANSACTIONS: " WS-COMPTEUR
           DISPLAY "MONTANT TOTAL: " WS-TOTAL " €"
           
           CLOSE FICHIER-TRANSACTION
           
           STOP RUN.
