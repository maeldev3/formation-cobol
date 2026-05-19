       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-PATIENTS.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-PATIENT ASSIGN TO 'data/input/PATIENTS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-PATIENT.
       01 ENR-PATIENT.
          05 ID-PAT          PIC X(6).
          05 FILLER          PIC X(1).
          05 NOM-PAT         PIC X(15).
          05 FILLER          PIC X(1).
          05 PRENOM-PAT      PIC X(10).
          05 FILLER          PIC X(1).
          05 DATE-NAISS      PIC X(10).
          05 FILLER          PIC X(1).
          05 SECU-PAT        PIC X(15).
          05 FILLER          PIC X(1).
          05 MUTUELLE-PAT    PIC X(6).
          05 FILLER          PIC X(1).
          05 CP-PAT          PIC X(5).
       
       WORKING-STORAGE SECTION.
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-COMPTEUR       PIC 99 VALUE 0.
       
       PROCEDURE DIVISION.
           OPEN INPUT FICHIER-PATIENT
           
           DISPLAY " "
           DISPLAY "=== LISTE DES PATIENTS ==="
           DISPLAY "ID     NOM              PRENOM     DATE NAISS   CP"
           DISPLAY "--------------------------------------------------"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-PATIENT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COMPTEUR
                       DISPLAY ID-PAT " " NOM-PAT " " 
                               PRENOM-PAT "   " DATE-NAISS " " CP-PAT
               END-READ
           END-PERFORM
           
           DISPLAY "--------------------------------------------------"
           DISPLAY "TOTAL PATIENTS: " WS-COMPTEUR
           
           CLOSE FICHIER-PATIENT
           
           STOP RUN.
