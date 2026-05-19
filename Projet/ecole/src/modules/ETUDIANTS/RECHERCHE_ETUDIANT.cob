       IDENTIFICATION DIVISION.
       PROGRAM-ID. RECHERCHE-ETUDIANT.
       
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
       01 WS-RECHERCHE       PIC X(6).
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-TROUVE          PIC X VALUE 'N'.
       
       PROCEDURE DIVISION.
           DISPLAY "=== RECHERCHE ETUDIANT ==="
           DISPLAY " "
           DISPLAY "ID a rechercher: "
           ACCEPT WS-RECHERCHE
           
           OPEN INPUT FICHIER-ETUDIANT
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-ETUDIANT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-ETU = WS-RECHERCHE
                           MOVE 'Y' TO WS-TROUVE
                           DISPLAY " "
                           DISPLAY "--- ETUDIANT TROUVE ---"
                           DISPLAY "ID      : " ID-ETU
                           DISPLAY "NOM     : " NOM-ETU
                           DISPLAY "PRENOM  : " PRENOM-ETU
                           DISPLAY "CLASSE  : " CLASSE-ETU
                           DISPLAY "DATE NAISS: " DATE-NAISS
                       END-IF
               END-READ
           END-PERFORM
           
           IF WS-TROUVE = 'N'
               DISPLAY "Etudiant non trouve"
           END-IF
           
           CLOSE FICHIER-ETUDIANT
           
           STOP RUN.
