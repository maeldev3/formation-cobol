       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUT-PATIENT.
       
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
       01 WS-NEW-ID          PIC X(6).
       01 WS-NEW-NOM         PIC X(15).
       01 WS-NEW-PRENOM      PIC X(10).
       01 WS-NEW-DATE        PIC X(10).
       01 WS-NEW-SECU        PIC X(15).
       01 WS-NEW-MUTUELLE    PIC X(6).
       01 WS-NEW-CP          PIC X(5).
       01 WS-AGE             PIC 99.
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-EXISTE          PIC X VALUE 'N'.
       
       PROCEDURE DIVISION.
           DISPLAY "=== AJOUTER UN PATIENT ==="
           DISPLAY " "
           
           DISPLAY "ID (P00011): "
           ACCEPT WS-NEW-ID
           DISPLAY "NOM: "
           ACCEPT WS-NEW-NOM
           DISPLAY "PRENOM: "
           ACCEPT WS-NEW-PRENOM
           DISPLAY "DATE NAISSANCE (YYYY-MM-DD): "
           ACCEPT WS-NEW-DATE
           DISPLAY "NUMERO SECU: "
           ACCEPT WS-NEW-SECU
           DISPLAY "MUTUELLE (MUT001/002/003): "
           ACCEPT WS-NEW-MUTUELLE
           DISPLAY "CODE POSTAL: "
           ACCEPT WS-NEW-CP
           
      *> Vérifier existence
           OPEN INPUT FICHIER-PATIENT
           MOVE 'N' TO WS-EXISTE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-PATIENT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-PAT = WS-NEW-ID
                           MOVE 'Y' TO WS-EXISTE
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-PATIENT
           
           IF WS-EXISTE = 'Y'
               DISPLAY "ERREUR: ID existe deja"
               STOP RUN
           END-IF
           
      *> Ajouter patient
           OPEN EXTEND FICHIER-PATIENT
           
           MOVE WS-NEW-ID TO ID-PAT
           MOVE WS-NEW-NOM TO NOM-PAT
           MOVE WS-NEW-PRENOM TO PRENOM-PAT
           MOVE WS-NEW-DATE TO DATE-NAISS
           MOVE WS-NEW-SECU TO SECU-PAT
           MOVE WS-NEW-MUTUELLE TO MUTUELLE-PAT
           MOVE WS-NEW-CP TO CP-PAT
           
           WRITE ENR-PATIENT
           CLOSE FICHIER-PATIENT
           
           DISPLAY " "
           DISPLAY "--- NOUVEAU PATIENT AJOUTE ---"
           DISPLAY "ID        : " WS-NEW-ID
           DISPLAY "NOM       : " WS-NEW-NOM
           DISPLAY "PRENOM    : " WS-NEW-PRENOM
           DISPLAY "DATE NAISS: " WS-NEW-DATE
           DISPLAY "SECU      : " WS-NEW-SECU
           DISPLAY "MUTUELLE  : " WS-NEW-MUTUELLE
           DISPLAY "CODE POSTAL: " WS-NEW-CP
           
           STOP RUN.
