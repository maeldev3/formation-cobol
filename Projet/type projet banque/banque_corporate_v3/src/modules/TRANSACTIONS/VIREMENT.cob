       IDENTIFICATION DIVISION.
       PROGRAM-ID. VIREMENT.
       
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
       01 WS-COMPTE-EMET    PIC X(6).
       01 WS-COMPTE-DEST    PIC X(6).
       01 WS-MONTANT        PIC 9(10)V99.
       01 WS-DATE           PIC X(10).
       01 WS-NEW-ID         PIC X(15).
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-EMET-TROUVE    PIC X VALUE 'N'.
       01 WS-DEST-TROUVE    PIC X VALUE 'N'.
       01 WS-COUNT          PIC 9(6) VALUE 0.
       01 WS-OLD-SOLDE-EMET PIC 9(10)V99.
       01 WS-OLD-SOLDE-DEST PIC 9(10)V99.
       01 WS-NEW-SOLDE-EMET PIC 9(10)V99.
       01 WS-NEW-SOLDE-DEST PIC 9(10)V99.
       01 WS-DECOUVERT      PIC 9(10)V99.
       01 WS-MONTANT-EDIT   PIC Z(9)9.99.
       
       PROCEDURE DIVISION.
           DISPLAY "=== VIREMENT ENTRE COMPTES ==="
           DISPLAY " "
           DISPLAY "COMPTE EMETTEUR: "
           ACCEPT WS-COMPTE-EMET
           DISPLAY "COMPTE DESTINATAIRE: "
           ACCEPT WS-COMPTE-DEST
           DISPLAY "MONTANT: "
           ACCEPT WS-MONTANT
           
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
           IF WS-COMPTE-EMET = WS-COMPTE-DEST
               DISPLAY "ERREUR: Impossible de faire virement sur meme compte"
               STOP RUN
           END-IF
           
      *> Verifier comptes
           OPEN INPUT FICHIER-COMPTE
           MOVE 'N' TO WS-FIN
           MOVE 'N' TO WS-EMET-TROUVE
           MOVE 'N' TO WS-DEST-TROUVE
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-COMPTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF NUM-COMPTE = WS-COMPTE-EMET
                           MOVE 'Y' TO WS-EMET-TROUVE
                           MOVE SOLDE-COMPTE TO WS-OLD-SOLDE-EMET
                           MOVE DECOUVERT TO WS-DECOUVERT
                       END-IF
                       IF NUM-COMPTE = WS-COMPTE-DEST
                           MOVE 'Y' TO WS-DEST-TROUVE
                           MOVE SOLDE-COMPTE TO WS-OLD-SOLDE-DEST
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-COMPTE
           
           IF WS-EMET-TROUVE = 'N'
               DISPLAY "ERREUR: Compte emetteur inexistant"
               STOP RUN
           END-IF
           
           IF WS-DEST-TROUVE = 'N'
               DISPLAY "ERREUR: Compte destinataire inexistant"
               STOP RUN
           END-IF
           
           IF WS-MONTANT > (WS-OLD-SOLDE-EMET + WS-DECOUVERT)
               DISPLAY "ERREUR: Solde insuffisant"
               DISPLAY "SOLDE EMETTEUR: " WS-OLD-SOLDE-EMET " €"
               STOP RUN
           END-IF
           
      *> Mettre a jour les comptes
           OPEN INPUT FICHIER-COMPTE
           OPEN OUTPUT FICHIER-TEMP
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-COMPTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF NUM-COMPTE = WS-COMPTE-EMET
                           SUBTRACT WS-MONTANT FROM SOLDE-COMPTE
                           MOVE SOLDE-COMPTE TO WS-NEW-SOLDE-EMET
                       END-IF
                       IF NUM-COMPTE = WS-COMPTE-DEST
                           ADD WS-MONTANT TO SOLDE-COMPTE
                           MOVE SOLDE-COMPTE TO WS-NEW-SOLDE-DEST
                       END-IF
                       MOVE ENR-COMPTE TO ENR-TEMP
                       WRITE ENR-TEMP
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-COMPTE, FICHIER-TEMP
           
           CALL 'SYSTEM' USING 
               'mv data/temp/COMPTES.TMP data/input/COMPTES.dat'
           
      *> Enregistrer transaction
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
           STRING 'VIR' WS-DATE WS-COUNT DELIMITED BY SIZE
               INTO WS-NEW-ID
           
           OPEN EXTEND FICHIER-TRANSACTION
           
           MOVE WS-NEW-ID TO ID-TRANS
           MOVE WS-COMPTE-EMET TO NUM-COMPTE-T
           MOVE WS-DATE TO DATE-TRANS
           MOVE WS-MONTANT TO MONTANT-TRANS
           MOVE 'VIREMENT' TO TYPE-TRANS
           MOVE 'SEPA' TO MODE-TRANS
           MOVE 'VALIDEE' TO STATUT-TRANS
           
           WRITE ENR-TRANS
           CLOSE FICHIER-TRANSACTION
           
           MOVE WS-MONTANT TO WS-MONTANT-EDIT
           
           DISPLAY " "
           DISPLAY "--- VIREMENT EFFECTUE ---"
           DISPLAY "COMPTE EMETTEUR  : " WS-COMPTE-EMET
           DISPLAY "COMPTE DESTINATAIRE: " WS-COMPTE-DEST
           DISPLAY "MONTANT          : " WS-MONTANT-EDIT " €"
           DISPLAY "DATE             : " WS-DATE
           DISPLAY "TRANSACTION      : " WS-NEW-ID
           DISPLAY "NOUVEAU SOLDE EMETTEUR: " WS-NEW-SOLDE-EMET " €"
           DISPLAY "NOUVEAU SOLDE DESTINATAIRE: " WS-NEW-SOLDE-DEST " €"
           
           STOP RUN.
