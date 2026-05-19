       IDENTIFICATION DIVISION.
       PROGRAM-ID. BATCH-HOPITAL.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-FACTURE ASSIGN TO 'data/input/FACTURES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-CONSULT ASSIGN TO 'data/input/CONSULTATIONS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-RAPPORT ASSIGN TO 'data/output/reports/RAPPORT_HOPITAL.rpt'
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
       
       FD FICHIER-CONSULT.
       01 ENR-CONSULT.
          05 ID-CONSULT      PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-PATIENT      PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-MEDECIN      PIC X(6).
          05 FILLER          PIC X(1).
          05 DATE-CONSULT    PIC X(10).
          05 FILLER          PIC X(1).
          05 DIAGNOSTIC      PIC X(30).
       
       FD FICHIER-RAPPORT.
       01 ENR-RAPPORT       PIC X(80).
       
       WORKING-STORAGE SECTION.
       01 WS-FIN-FACT       PIC X VALUE 'N'.
       01 WS-FIN-CONS       PIC X VALUE 'N'.
       01 WS-DATE           PIC X(10).
       01 WS-TOTAL-IMP      PIC 9(9)V99 VALUE 0.
       01 WS-TOTAL-CONS     PIC 99 VALUE 0.
       01 WS-COMPTEUR-IMP   PIC 99 VALUE 0.
       
       PROCEDURE DIVISION.
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
           OPEN INPUT FICHIER-FACTURE
           OPEN INPUT FICHIER-CONSULT
           OPEN OUTPUT FICHIER-RAPPORT
           
      *> En-tête
           STRING "RAPPORT HOPITAL - " WS-DATE INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           MOVE SPACES TO ENR-RAPPORT
           STRING "=================================" INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
      *> Statistiques consultations
           MOVE 'N' TO WS-FIN-CONS
           PERFORM UNTIL WS-FIN-CONS = 'Y'
               READ FICHIER-CONSULT
                   AT END MOVE 'Y' TO WS-FIN-CONS
                   NOT AT END
                       ADD 1 TO WS-TOTAL-CONS
               END-READ
           END-PERFORM
           
           MOVE SPACES TO ENR-RAPPORT
           STRING "Total consultations: " WS-TOTAL-CONS
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
      *> Factures impayées
           MOVE 'N' TO WS-FIN-FACT
           PERFORM UNTIL WS-FIN-FACT = 'Y'
               READ FICHIER-FACTURE
                   AT END MOVE 'Y' TO WS-FIN-FACT
                   NOT AT END
                       IF STATUT-F = 'I'
                           ADD 1 TO WS-COMPTEUR-IMP
                           ADD MONTANT-F TO WS-TOTAL-IMP
                           MOVE SPACES TO ENR-RAPPORT
                           STRING "Facture impayee: " ID-FACTURE " - "
                                   MONTANT-F " €"
                               INTO ENR-RAPPORT
                           WRITE ENR-RAPPORT
                       END-IF
               END-READ
           END-PERFORM
           
           MOVE SPACES TO ENR-RAPPORT
           STRING "Total factures impayees: " WS-COMPTEUR-IMP
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           MOVE SPACES TO ENR-RAPPORT
           STRING "Montant total impaye: " WS-TOTAL-IMP " €"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           CLOSE FICHIER-FACTURE, FICHIER-CONSULT, FICHIER-RAPPORT
           
           DISPLAY " "
           DISPLAY "=== BATCH HOPITAL TERMINE ==="
           DISPLAY "Consultations: " WS-TOTAL-CONS
           DISPLAY "Factures impayees: " WS-COMPTEUR-IMP
           DISPLAY "Montant impaye: " WS-TOTAL-IMP " €"
           DISPLAY "Rapport: data/output/reports/RAPPORT_HOPITAL.rpt"
           
           STOP RUN.
