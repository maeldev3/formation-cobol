       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-ETUDIANTS.
       
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
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-COMPTEUR       PIC 99 VALUE 0.
       
       PROCEDURE DIVISION.
           OPEN INPUT FICHIER-ETUDIANT
           
           DISPLAY " "
           DISPLAY "=== LISTE DES ETUDIANTS ==="
           DISPLAY "ID     NOM              PRENOM     CLASSE  DATE NAISS"
           DISPLAY "------------------------------------------------------"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-ETUDIANT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COMPTEUR
                       DISPLAY ID-ETU " " NOM-ETU " " 
                               PRENOM-ETU "   " CLASSE-ETU "    " DATE-NAISS
               END-READ
           END-PERFORM
           
           DISPLAY "------------------------------------------------------"
           DISPLAY "TOTAL ETUDIANTS: " WS-COMPTEUR
           
           CLOSE FICHIER-ETUDIANT
           
           STOP RUN.
