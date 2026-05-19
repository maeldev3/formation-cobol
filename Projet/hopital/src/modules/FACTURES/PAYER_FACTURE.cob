       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAYER-FACTURE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-FACTURE ASSIGN TO 'data/input/FACTURES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-TEMP ASSIGN TO 'data/input/FACTURES.TMP'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-FACTURE.
       01 ENR-FACTURE.
          05 ID-FACTURE      PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-CONSULT-F    PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-PATIENT-F    PIC X(6).
          05 FILLER          PIC X(1).
          05 MONTANT-F       PIC 9(6)V99.
          05 FILLER          PIC X(1).
          05 DATE-FACTURE    PIC X(10).
          05 FILLER          PIC X(1).
          05 STATUT-F        PIC X(1).
       
       FD FICHIER-TEMP.
       01 ENR-TEMP          PIC X(80).
       
       WORKING-STORAGE SECTION.
       01 WS-ID-FACT        PIC X(6).
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-TROUVE         PIC X VALUE 'N'.
       01 WS-STATUT         PIC X(1).
       
       PROCEDURE DIVISION.
           DISPLAY "=== PAYER UNE FACTURE ==="
           DISPLAY " "
           DISPLAY "ID FACTURE: "
           ACCEPT WS-ID-FACT
           
           OPEN INPUT FICHIER-FACTURE
           OPEN OUTPUT FICHIER-TEMP
           
           MOVE 'N' TO WS-FIN
           MOVE 'N' TO WS-TROUVE
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-FACTURE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-FACTURE = WS-ID-FACT
                           MOVE 'Y' TO WS-TROUVE
                           MOVE 'P' TO STATUT-F
                       END-IF
                       MOVE ENR-FACTURE TO ENR-TEMP
                       WRITE ENR-TEMP
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-FACTURE, FICHIER-TEMP
           
           IF WS-TROUVE = 'Y'
               CALL 'SYSTEM' USING 'mv data/input/FACTURES.TMP data/input/FACTURES.DAT'
               DISPLAY "Facture " WS-ID-FACT " payee"
           ELSE
               DISPLAY "Facture non trouvee"
               CALL 'SYSTEM' USING 'rm data/input/FACTURES.TMP'
           END-IF
           
           STOP RUN.
