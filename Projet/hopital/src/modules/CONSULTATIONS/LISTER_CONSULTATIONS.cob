       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-CONSULTATIONS.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CONSULT ASSIGN TO 'data/input/CONSULTATIONS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
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
       
       WORKING-STORAGE SECTION.
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-COMPTEUR       PIC 99 VALUE 0.
       
       PROCEDURE DIVISION.
           OPEN INPUT FICHIER-CONSULT
           
           DISPLAY " "
           DISPLAY "=== LISTE DES CONSULTATIONS ==="
           DISPLAY "ID      PATIENT  MEDECIN  DATE       DIAGNOSTIC"
           DISPLAY "------------------------------------------------"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CONSULT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COMPTEUR
                       DISPLAY ID-CONSULT " " ID-PATIENT "   " 
                               ID-MEDECIN "   " DATE-CONSULT "   "
                               DIAGNOSTIC
               END-READ
           END-PERFORM
           
           DISPLAY "------------------------------------------------"
           DISPLAY "TOTAL CONSULTATIONS: " WS-COMPTEUR
           
           CLOSE FICHIER-CONSULT
           
           STOP RUN.
