       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-PAIEMENTS.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-PAIEMENT ASSIGN TO 'data/input/PAIEMENTS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-PAIEMENT.
       01 ENR-PAIEMENT.
          05 ID-SIN-PAIE     PIC X(10).
          05 FILLER          PIC X(1).
          05 MONTANT-PAIE    PIC 9(8)V99.
          05 FILLER          PIC X(1).
          05 DATE-PAIE       PIC X(10).
       
       WORKING-STORAGE SECTION.
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-COMPTEUR       PIC 99 VALUE 0.
       01 WS-TOTAL          PIC 9(9)V99 VALUE 0.
       
       PROCEDURE DIVISION.
           OPEN INPUT FICHIER-PAIEMENT
           
           DISPLAY " "
           DISPLAY "=== LISTE DES PAIEMENTS ==="
           DISPLAY "ID SINISTRE  MONTANT     DATE PAIEMENT"
           DISPLAY "----------------------------------------"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-PAIEMENT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COMPTEUR
                       ADD MONTANT-PAIE TO WS-TOTAL
                       DISPLAY ID-SIN-PAIE "   " MONTANT-PAIE " €     " DATE-PAIE
               END-READ
           END-PERFORM
           
           DISPLAY "----------------------------------------"
           DISPLAY "TOTAL PAIEMENTS: " WS-COMPTEUR
           DISPLAY "MONTANT TOTAL: " WS-TOTAL " €"
           
           CLOSE FICHIER-PAIEMENT
           
           STOP RUN.
