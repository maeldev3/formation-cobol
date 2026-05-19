       IDENTIFICATION DIVISION.
       PROGRAM-ID. VIREMENT.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-COMPTE ASSIGN TO 'data/input/COMPTES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-TRANSACTION ASSIGN TO 'data/input/TRANSACTIONS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-TEMP ASSIGN TO 'data/input/COMPTES.TMP'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-COMPTE.
       01 ENR-COMPTE.
          05 NUM-COMPTE      PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-CLIENT-C     PIC X(6).
          05 FILLER          PIC X(1).
          05 TYPE-COMPTE     PIC X(4).
          05 FILLER          PIC X(1).
          05 SOLDE-COMPTE    PIC 9(9)V99.
          05 FILLER          PIC X(1).
          05 DATE-OUV-COMP   PIC X(10).
       
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
       
       FD FICHIER-TEMP.
       01 ENR-TEMP          PIC X(80).
       
       WORKING-STORAGE SECTION.
       01 WS-COMPTE-EMET     PIC X(6).
       01 WS-COMPTE-DEST     PIC X(6).
       01 WS-MONTANT         PIC 9(8)V99.
       01 WS-SOLDE-EMET      PIC 9(9)V99.
       01 WS-DATE            PIC X(10).
       01 WS-NEW-ID          PIC X(6).
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-EMET-TROUVE     PIC X VALUE 'N'.
       01 WS-DEST-TROUVE     PIC X VALUE 'N'.
       01 WS-COMPTEUR        PIC 99.
       
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
           
      *> Vérifier comptes
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
                           MOVE SOLDE-COMPTE TO WS-SOLDE-EMET
                       END-IF
                       IF NUM-COMPTE = WS-COMPTE-DEST
                           MOVE 'Y' TO WS-DEST-TROUVE
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
           
           IF WS-MONTANT > WS-SOLDE-EMET
               DISPLAY "ERREUR: Solde insuffisant"
               DISPLAY "SOLDE ACTUEL: " WS-SOLDE-EMET " €"
               STOP RUN
           END-IF
           
      *> Mettre à jour les comptes
           OPEN INPUT FICHIER-COMPTE
           OPEN OUTPUT FICHIER-TEMP
           
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-COMPTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF NUM-COMPTE = WS-COMPTE-EMET
                           COMPUTE SOLDE-COMPTE = 
                               SOLDE-COMPTE - WS-MONTANT
                       END-IF
                       IF NUM-COMPTE = WS-COMPTE-DEST
                           COMPUTE SOLDE-COMPTE = 
                               SOLDE-COMPTE + WS-MONTANT
                       END-IF
                       MOVE ENR-COMPTE TO ENR-TEMP
                       WRITE ENR-TEMP
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-COMPTE, FICHIER-TEMP
           CALL 'SYSTEM' USING 'mv data/input/COMPTES.TMP data/input/COMPTES.DAT'
           
      *> Enregistrer les transactions
           OPEN EXTEND FICHIER-TRANSACTION
           
           OPEN INPUT FICHIER-TRANSACTION
           MOVE 1 TO WS-COMPTEUR
           MOVE 'N' TO WS-FIN
           PERFORM UNTIL WS-FIN = 'Y'
               MOVE WS-COMPTEUR TO WS-NEW-ID(5:2)
               MOVE 'T' TO WS-NEW-ID(1:1)
               MOVE '0' TO WS-NEW-ID(2:1)
               MOVE '0' TO WS-NEW-ID(3:1)
               MOVE '0' TO WS-NEW-ID(4:1)
               READ FICHIER-TRANSACTION
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-TRANS = WS-NEW-ID
                           ADD 1 TO WS-COMPTEUR
                       END-IF
           END-PERFORM
           CLOSE FICHIER-TRANSACTION
           
           MOVE WS-NEW-ID TO ID-TRANS
           MOVE WS-COMPTE-EMET TO NUM-COMPTE-T
           MOVE WS-DATE TO DATE-TRANS
           MOVE WS-MONTANT TO MONTANT-TRANS
           MOVE 'VIREMENT' TO TYPE-TRANS
           WRITE ENR-TRANS
           
           CLOSE FICHIER-TRANSACTION
           
           DISPLAY " "
           DISPLAY "--- VIREMENT EFFECTUE ---"
           DISPLAY "COMPTE EMETTEUR  : " WS-COMPTE-EMET
           DISPLAY "COMPTE DESTINATAIRE: " WS-COMPTE-DEST
           DISPLAY "MONTANT          : " WS-MONTANT " €"
           DISPLAY "DATE             : " WS-DATE
           
           STOP RUN.
