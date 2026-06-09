       IDENTIFICATION DIVISION.
       PROGRAM-ID. RETRAIT.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-COMPTE ASSIGN TO 'data/input/COMPTES.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-TRANSACTION ASSIGN TO 'data/input/TRANSACTIONS.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-TEMP ASSIGN TO 'data/temp/COMPTES.TMP'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-COMPTE.
       01 ENR-COMPTE.
          05 NUM-COMPTE      PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-CLI-COMPTE   PIC X(6).
          05 FILLER          PIC X(1).
          05 TYPE-COMPTE     PIC X(10).
          05 FILLER          PIC X(1).
          05 SOLDE-COMPTE    PIC 9(10)V99.
          05 FILLER          PIC X(1).
          05 DECOUVERT       PIC 9(10)V99.
          05 FILLER          PIC X(1).
          05 DATE-OUV        PIC X(10).
          05 FILLER          PIC X(1).
          05 STATUT-COMPTE   PIC X(6).
       
       FD FICHIER-TRANSACTION.
       01 ENR-TRANS.
          05 ID-TRANS        PIC X(15).
          05 FILLER          PIC X(1).
          05 NUM-COMPTE-T    PIC X(6).
          05 FILLER          PIC X(1).
          05 DATE-TRANS      PIC X(10).
          05 FILLER          PIC X(1).
          05 MONTANT-TRANS   PIC 9(10)V99.
          05 FILLER          PIC X(1).
          05 TYPE-TRANS      PIC X(15).
          05 FILLER          PIC X(1).
          05 MODE-TRANS      PIC X(10).
          05 FILLER          PIC X(1).
          05 STATUT-TRANS    PIC X(7).
       
       FD FICHIER-TEMP.
       01 ENR-TEMP          PIC X(80).
       
       WORKING-STORAGE SECTION.
       01 WS-NUM-COMPTE     PIC X(6).
       01 WS-MONTANT        PIC 9(10)V99.
       01 WS-NOUV-SOLDE     PIC 9(10)V99.
       01 WS-DATE           PIC X(10).
       01 WS-NEW-ID         PIC X(15).
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-TROUVE         PIC X VALUE 'N'.
       01 WS-COUNT          PIC 9(6) VALUE 0.
       01 WS-OLD-SOLDE      PIC 9(10)V99.
       01 WS-DECOUVERT      PIC 9(10)V99.
       01 WS-MONTANT-EDIT   PIC Z(9)9.99.
       01 WS-SOLDE-EDIT     PIC Z(9)9.99.
       
       PROCEDURE DIVISION.
           DISPLAY "=== RETRAIT D'ARGENT ==="
           DISPLAY " "
           DISPLAY "NUMERO DE COMPTE: "
           ACCEPT WS-NUM-COMPTE
           DISPLAY "MONTANT A RETIRER: "
           ACCEPT WS-MONTANT
           
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
      *> Verifier solde
           OPEN INPUT FICHIER-COMPTE
           MOVE 'N' TO WS-FIN
           MOVE 'N' TO WS-TROUVE
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-COMPTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF NUM-COMPTE = WS-NUM-COMPTE
                           MOVE 'Y' TO WS-TROUVE
                           MOVE SOLDE-COMPTE TO WS-OLD-SOLDE
                           MOVE DECOUVERT TO WS-DECOUVERT
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-COMPTE
           
           IF WS-TROUVE = 'N'
               DISPLAY "ERREUR: Compte non trouve"
               STOP RUN
           END-IF
           
           IF WS-MONTANT > (WS-OLD-SOLDE + WS-DECOUVERT)
               DISPLAY "ERREUR: Solde insuffisant"
               DISPLAY "SOLDE: " WS-OLD-SOLDE " €"
               DISPLAY "DECOUVERT AUTORISE: " WS-DECOUVERT " €"
               STOP RUN
           END-IF
           
      *> Mettre a jour le solde
           OPEN INPUT FICHIER-COMPTE
           OPEN OUTPUT FICHIER-TEMP
           MOVE 'N' TO WS-FIN
           MOVE 'N' TO WS-TROUVE
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-COMPTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF NUM-COMPTE = WS-NUM-COMPTE
                           MOVE 'Y' TO WS-TROUVE
                           SUBTRACT WS-MONTANT FROM SOLDE-COMPTE
                           MOVE SOLDE-COMPTE TO WS-NOUV-SOLDE
                       END-IF
                       MOVE ENR-COMPTE TO ENR-TEMP
                       WRITE ENR-TEMP
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-COMPTE, FICHIER-TEMP
           
           CALL 'SYSTEM' USING 
               'mv data/temp/COMPTES.TMP data/input/COMPTES.dat'
           
      *> Generer ID transaction
           OPEN INPUT FICHIER-TRANSACTION
           MOVE 0 TO WS-COUNT
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-TRANSACTION
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COUNT
               END-READ
           END-PERFORM
           CLOSE FICHIER-TRANSACTION
           
           ADD 1 TO WS-COUNT
           STRING 'RET' WS-DATE WS-COUNT DELIMITED BY SIZE
               INTO WS-NEW-ID
           
      *> Enregistrer transaction
           OPEN EXTEND FICHIER-TRANSACTION
           
           MOVE WS-NEW-ID TO ID-TRANS
           MOVE WS-NUM-COMPTE TO NUM-COMPTE-T
           MOVE WS-DATE TO DATE-TRANS
           MOVE WS-MONTANT TO MONTANT-TRANS
           MOVE 'RETRAIT' TO TYPE-TRANS
           MOVE 'ESPECES' TO MODE-TRANS
           MOVE 'VALIDEE' TO STATUT-TRANS
           
           WRITE ENR-TRANS
           CLOSE FICHIER-TRANSACTION
           
           MOVE WS-MONTANT TO WS-MONTANT-EDIT
           MOVE WS-NOUV-SOLDE TO WS-SOLDE-EDIT
           
           DISPLAY " "
           DISPLAY "--- RETRAIT EFFECTUE ---"
           DISPLAY "COMPTE       : " WS-NUM-COMPTE
           DISPLAY "MONTANT      : " WS-MONTANT-EDIT " €"
           DISPLAY "ANCIEN SOLDE : " WS-OLD-SOLDE " €"
           DISPLAY "NOUVEAU SOLDE: " WS-SOLDE-EDIT " €"
           DISPLAY "DATE         : " WS-DATE
           DISPLAY "TRANSACTION  : " WS-NEW-ID
           
           STOP RUN.
