       IDENTIFICATION DIVISION.
       PROGRAM-ID. RECHERCHE-PATIENT.
       
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
       01 WS-RECHERCHE       PIC X(6).
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-TROUVE          PIC X VALUE 'N'.
       
       PROCEDURE DIVISION.
           DISPLAY "=== RECHERCHE PATIENT ==="
           DISPLAY " "
           DISPLAY "ID a rechercher: "
           ACCEPT WS-RECHERCHE
           
           OPEN INPUT FICHIER-PATIENT
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-PATIENT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-PAT = WS-RECHERCHE
                           MOVE 'Y' TO WS-TROUVE
                           DISPLAY " "
                           DISPLAY "--- PATIENT TROUVE ---"
                           DISPLAY "ID        : " ID-PAT
                           DISPLAY "NOM       : " NOM-PAT
                           DISPLAY "PRENOM    : " PRENOM-PAT
                           DISPLAY "DATE NAISS: " DATE-NAISS
                           DISPLAY "SECU      : " SECU-PAT
                           DISPLAY "MUTUELLE  : " MUTUELLE-PAT
                           DISPLAY "CODE POSTAL: " CP-PAT
                       END-IF
               END-READ
           END-PERFORM
           
           IF WS-TROUVE = 'N'
               DISPLAY "Patient non trouve"
           END-IF
           
           CLOSE FICHIER-PATIENT
           
           STOP RUN.
