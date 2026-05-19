       IDENTIFICATION DIVISION.
       PROGRAM-ID. BATCH-QUOTIDIEN.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-SINISTRE ASSIGN TO 'data/input/SINISTRES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-PAIEMENT ASSIGN TO 'data/input/PAIEMENTS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-RAPPORT ASSIGN TO 'data/output/reports/SINISTRES_RAPPORT.rpt'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
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
       
       FD FICHIER-PAIEMENT.
       01 ENR-PAIEMENT.
          05 ID-SIN-PAIE     PIC X(10).
          05 FILLER          PIC X(1).
          05 MONTANT-PAIE    PIC 9(8)V99.
          05 FILLER          PIC X(1).
          05 DATE-PAIE       PIC X(10).
       
       FD FICHIER-RAPPORT.
       01 ENR-RAPPORT       PIC X(80).
       
       WORKING-STORAGE SECTION.
       01 WS-FIN-SIN        PIC X VALUE 'N'.
       01 WS-FIN-PAI        PIC X VALUE 'N'.
       01 WS-DATE-COURANTE  PIC X(10).
       01 WS-TOTAL-DEM      PIC 9(9)V99 VALUE 0.
       01 WS-TOTAL-PAYE     PIC 9(9)V99 VALUE 0.
       01 WS-COMPTEUR-SIN   PIC 99 VALUE 0.
       01 WS-COMPTEUR-PAYE  PIC 99 VALUE 0.
       
       PROCEDURE DIVISION.
           ACCEPT WS-DATE-COURANTE FROM DATE YYYYMMDD
           
           OPEN INPUT FICHIER-SINISTRE
           OPEN INPUT FICHIER-PAIEMENT
           OPEN OUTPUT FICHIER-RAPPORT
           
      *> En-tête rapport
           STRING "RAPPORT SINISTRES - " WS-DATE-COURANTE
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           MOVE SPACES TO ENR-RAPPORT
           STRING "SINISTRES EN COURS (STATUS O) :"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           MOVE SPACES TO ENR-RAPPORT
           STRING "ID           MONTANT   DATE"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
      *> Compter sinistres ouverts
           MOVE 'N' TO WS-FIN-SIN
           PERFORM UNTIL WS-FIN-SIN = 'Y'
               READ FICHIER-SINISTRE
                   AT END MOVE 'Y' TO WS-FIN-SIN
                   NOT AT END
                       IF STATUS-SIN = 'O'
                           ADD 1 TO WS-COMPTEUR-SIN
                           ADD MONTANT-SIN TO WS-TOTAL-DEM
                           STRING ID-SIN "     " MONTANT-SIN "   " DATE-SIN
                               INTO ENR-RAPPORT
                           WRITE ENR-RAPPORT
                       END-IF
               END-READ
           END-PERFORM
           
      *> Total sinistres ouverts
           MOVE SPACES TO ENR-RAPPORT
           STRING "TOTAL SINISTRES OUVERTS: " WS-COMPTEUR-SIN
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           MOVE SPACES TO ENR-RAPPORT
           STRING "MONTANT TOTAL DEMANDE: " WS-TOTAL-DEM " €"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
      *> Paiements effectués
           MOVE SPACES TO ENR-RAPPORT
           STRING "PAIEMENTS EFFECTUES :"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           MOVE 'N' TO WS-FIN-PAI
           PERFORM UNTIL WS-FIN-PAI = 'Y'
               READ FICHIER-PAIEMENT
                   AT END MOVE 'Y' TO WS-FIN-PAI
                   NOT AT END
                       ADD 1 TO WS-COMPTEUR-PAYE
                       ADD MONTANT-PAIE TO WS-TOTAL-PAYE
                       STRING ID-SIN-PAIE "     " MONTANT-PAIE "   " DATE-PAIE
                           INTO ENR-RAPPORT
                       WRITE ENR-RAPPORT
               END-READ
           END-PERFORM
           
           MOVE SPACES TO ENR-RAPPORT
           STRING "TOTAL PAIEMENTS: " WS-TOTAL-PAYE " €"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           CLOSE FICHIER-SINISTRE, FICHIER-PAIEMENT, FICHIER-RAPPORT
           
           DISPLAY " "
           DISPLAY "=== BATCH QUOTIDIEN TERMINE ==="
           DISPLAY "Sinistres ouverts: " WS-COMPTEUR-SIN
           DISPLAY "Montant total demande: " WS-TOTAL-DEM " €"
           DISPLAY "Paiements effectues: " WS-COMPTEUR-PAYE
           DISPLAY "Montant total paye: " WS-TOTAL-PAYE " €"
           DISPLAY "Rapport: data/output/reports/SINISTRES_RAPPORT.rpt"
           
           STOP RUN.
