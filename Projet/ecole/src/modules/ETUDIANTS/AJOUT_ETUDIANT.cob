       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUT-ETUDIANT.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-ETUDIANT ASSIGN TO 'data/input/ETUDIANTS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-ETUDIANT.
       01 ENR-ETUDIANT.
          05 ID-ETU          PIC X(6).
          05 FILLER          PIC X(1).
          05 NOM-ETU         PIC X(15).
          05 FILLER          PIC X(1).
          05 PRENOM-ETU      PIC X(10).
          05 FILLER          PIC X(1).
          05 DATE-NAISS      PIC X(10).
          05 FILLER          PIC X(1).
          05 CLASSE-ETU      PIC X(3).
       
       WORKING-STORAGE SECTION.
       01 WS-NEW-ID          PIC X(6).
       01 WS-NEW-NOM         PIC X(15).
       01 WS-NEW-PRENOM      PIC X(10).
       01 WS-NEW-DATE        PIC X(10).
       01 WS-NEW-CLASSE      PIC X(3).
       01 WS-AGE             PIC 99.
       01 WS-ANNEE           PIC 9(4).
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-EXISTE          PIC X VALUE 'N'.
       
       PROCEDURE DIVISION.
           DISPLAY "=== AJOUTER UN ETUDIANT ==="
           DISPLAY " "
           
           DISPLAY "ID (E00011): "
           ACCEPT WS-NEW-ID
           DISPLAY "NOM: "
           ACCEPT WS-NEW-NOM
           DISPLAY "PRENOM: "
           ACCEPT WS-NEW-PRENOM
           DISPLAY "DATE NAISSANCE (DD/MM/YYYY): "
           ACCEPT WS-NEW-DATE
           DISPLAY "CLASSE (3A,3B,4A,4B): "
           ACCEPT WS-NEW-CLASSE
           
      *> Vérifier existence
           OPEN INPUT FICHIER-ETUDIANT
           MOVE 'N' TO WS-EXISTE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-ETUDIANT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-ETU = WS-NEW-ID
                           MOVE 'Y' TO WS-EXISTE
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-ETUDIANT
           
           IF WS-EXISTE = 'Y'
               DISPLAY "ERREUR: ID existe deja"
               STOP RUN
           END-IF
           
      *> Ajouter étudiant
           OPEN EXTEND FICHIER-ETUDIANT
           
           MOVE WS-NEW-ID TO ID-ETU
           MOVE WS-NEW-NOM TO NOM-ETU
           MOVE WS-NEW-PRENOM TO PRENOM-ETU
           MOVE WS-NEW-DATE TO DATE-NAISS
           MOVE WS-NEW-CLASSE TO CLASSE-ETU
           
           WRITE ENR-ETUDIANT
           CLOSE FICHIER-ETUDIANT
           
           DISPLAY " "
           DISPLAY "--- NOUVEL ETUDIANT AJOUTE ---"
           DISPLAY "ID      : " WS-NEW-ID
           DISPLAY "NOM     : " WS-NEW-NOM
           DISPLAY "PRENOM  : " WS-NEW-PRENOM
           DISPLAY "DATE NAISS: " WS-NEW-DATE
           DISPLAY "CLASSE  : " WS-NEW-CLASSE
           
           STOP RUN.
