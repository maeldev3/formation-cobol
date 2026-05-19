       IDENTIFICATION DIVISION.
       PROGRAM-ID. INDEMNISER.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-PAIEMENT ASSIGN TO 'data/input/PAIEMENTS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-SINISTRE ASSIGN TO 'data/input/SINISTRES.DAT'
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
       
       FD FICHIER-SINISTRE.
       01 ENR-SINISTRE.
          05 ID-SIN          PIC X(10).
          05 FILLER          PIC X(1).
          05 NUM-CONTRAT     PIC X(10).
          05 FILLER          PIC X(1).
          05 DATE-SIN        PIC X(10).
          05 FILLER          PIC X(1).
          05 MONTANT-SIN     PIC 9(8)V99.
          05 FILLER          PIC X(1).
          05 STATUS-SIN      PIC X(1).
       
       WORKING-STORAGE SECTION.
       01 WS-ID-SIN          PIC X(10).
       01 WS-MONTANT         PIC 9(8)V99.
       01 WS-DATE            PIC X(10).
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-TROUVE          PIC X VALUE 'N'.
       01 WS-MONTANT-DEM     PIC 9(8)V99.
       
       PROCEDURE DIVISION.
           DISPLAY "=== INDEMNISER UN SINISTRE ==="
           DISPLAY " "
           DISPLAY "ID SINISTRE : "
           ACCEPT WS-ID-SIN
           DISPLAY "MONTANT INDEMNISE : "
           ACCEPT WS-MONTANT
           
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
      *> Vérifier que le sinistre existe et est ouvert
           OPEN INPUT FICHIER-SINISTRE
           MOVE 'N' TO WS-TROUVE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-SINISTRE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-SIN = WS-ID-SIN
                           MOVE 'Y' TO WS-TROUVE
                           MOVE MONTANT-SIN TO WS-MONTANT-DEM
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-SINISTRE
           
           IF WS-TROUVE = 'N'
               DISPLAY "ERREUR: Sinistre non trouve"
               STOP RUN
           END-IF
           
           IF WS-MONTANT > WS-MONTANT-DEM
               DISPLAY "ERREUR: Montant indemnite superieur a la demande"
               DISPLAY "Demande: " WS-MONTANT-DEM " €"
               STOP RUN
           END-IF
           
      *> Enregistrer le paiement
           OPEN EXTEND FICHIER-PAIEMENT
           
           MOVE WS-ID-SIN TO ID-SIN-PAIE
           MOVE WS-MONTANT TO MONTANT-PAIE
           MOVE WS-DATE TO DATE-PAIE
           
           WRITE ENR-PAIEMENT
           CLOSE FICHIER-PAIEMENT
           
           DISPLAY " "
           DISPLAY "--- INDEMNISATION ENREGISTREE ---"
           DISPLAY "SINISTRE    : " WS-ID-SIN
           DISPLAY "MONTANT     : " WS-MONTANT " €"
           DISPLAY "DATE PAIEMENT: " WS-DATE
           
           STOP RUN.
