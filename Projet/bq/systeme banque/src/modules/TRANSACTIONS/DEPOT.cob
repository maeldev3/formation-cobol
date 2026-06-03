       IDENTIFICATION DIVISION.
       PROGRAM-ID. DEPOT.
       
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
       01 WS-NUM-COMPTE      PIC X(6).
       01 WS-MONTANT         PIC 9(8)V99.
       01 WS-NOUV-SOLDE      PIC 9(9)V99.
       01 WS-DATE            PIC X(10).
       01 WS-NEW-ID          PIC X(6).
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-TROUVE          PIC X VALUE 'N'.
       01 WS-COUNT           PIC 9(6) VALUE 0.
       01 WS-CMD             PIC X(200).
       
       PROCEDURE DIVISION.
           DISPLAY "=== DEPOT D'ARGENT ==="
           DISPLAY " "
           DISPLAY "NUMERO DE COMPTE: "
           ACCEPT WS-NUM-COMPTE
           DISPLAY "MONTANT A DEPOSER: "
           ACCEPT WS-MONTANT
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
      *> ÉTAPE 1: Mettre à jour le compte
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
                           ADD WS-MONTANT TO SOLDE-COMPTE
                           MOVE SOLDE-COMPTE TO WS-NOUV-SOLDE
                       END-IF
                       MOVE ENR-COMPTE TO ENR-TEMP
                       WRITE ENR-TEMP
               END-READ
           END-PERFORM
           CLOSE FICHIER-COMPTE, FICHIER-TEMP
           
           IF WS-TROUVE = 'N'
               DISPLAY "ERREUR: Compte non trouve"
               STOP RUN
           END-IF
           
           MOVE 'mv data/input/COMPTES.TMP data/input/COMPTES.DAT' 
               TO WS-CMD
           CALL 'SYSTEM' USING WS-CMD
           
      *> ÉTAPE 2: Compter les transactions (une seule ouverture)
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
           
      *> ÉTAPE 3: Générer l'ID (T + 5 chiffres)
           ADD 1 TO WS-COUNT
           MOVE 'T' TO WS-NEW-ID(1:1)
           MOVE WS-COUNT TO WS-NEW-ID(2:5)
           
      *> ÉTAPE 4: Ajouter la transaction
           OPEN EXTEND FICHIER-TRANSACTION
           MOVE WS-NEW-ID TO ID-TRANS
           MOVE WS-NUM-COMPTE TO NUM-COMPTE-T
           MOVE WS-DATE TO DATE-TRANS
           MOVE WS-MONTANT TO MONTANT-TRANS
           MOVE 'DEPOT' TO TYPE-TRANS
           WRITE ENR-TRANS
           CLOSE FICHIER-TRANSACTION
           
           DISPLAY " "
           DISPLAY "--- DEPOT EFFECTUE ---"
           DISPLAY "COMPTE    : " WS-NUM-COMPTE
           DISPLAY "MONTANT   : " WS-MONTANT " €"
           DISPLAY "SOLDE     : " WS-NOUV-SOLDE " €"
           DISPLAY "DATE      : " WS-DATE
           DISPLAY "TRANS     : " WS-NEW-ID
           
           STOP RUN.