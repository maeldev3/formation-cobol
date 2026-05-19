       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-FACTURES.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-FACTURE ASSIGN TO 'data/input/FACTURES.DAT'
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
       
       WORKING-STORAGE SECTION.
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-COMPTEUR       PIC 99 VALUE 0.
       01 WS-TOTAL          PIC 9(9)V99 VALUE 0.
       
       PROCEDURE DIVISION.
           OPEN INPUT FICHIER-FACTURE
           
           DISPLAY " "
           DISPLAY "=== LISTE DES FACTURES ==="
           DISPLAY "ID      CONSULT   PATIENT  MONTANT   DATE       STATUT"
           DISPLAY "------------------------------------------------------"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-FACTURE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COMPTEUR
                       ADD MONTANT-F TO WS-TOTAL
                       DISPLAY ID-FACTURE " " ID-CONSULT-F "   "
                               ID-PATIENT-F "   " MONTANT-F " €  "
                               DATE-FACTURE "   " STATUT-F
               END-READ
           END-PERFORM
           
           DISPLAY "------------------------------------------------------"
           DISPLAY "TOTAL FACTURES: " WS-COMPTEUR
           DISPLAY "MONTANT TOTAL: " WS-TOTAL " €"
           
           CLOSE FICHIER-FACTURE
           
           STOP RUN.
