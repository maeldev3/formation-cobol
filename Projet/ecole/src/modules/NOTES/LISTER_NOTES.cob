       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-NOTES.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-NOTE ASSIGN TO 'data/input/NOTES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-ETUDIANT ASSIGN TO 'data/input/ETUDIANTS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-COURS ASSIGN TO 'data/input/COURS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-NOTE.
       01 ENR-NOTE.
          05 ID-NOTE         PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-ETU-NOTE     PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-COURS-NOTE   PIC X(6).
          05 FILLER          PIC X(1).
          05 VALEUR-NOTE     PIC 9(4)V99.
          05 FILLER          PIC X(1).
          05 DATE-NOTE       PIC X(10).
       
       FD FICHIER-ETUDIANT.
       01 ENR-ETUDIANT.
          05 ID-ETU          PIC X(6).
          05 NOM-ETU         PIC X(15).
       
       FD FICHIER-COURS.
       01 ENR-COURS.
          05 ID-COURS        PIC X(6).
          05 NOM-COURS       PIC X(30).
       
       WORKING-STORAGE SECTION.
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-COMPTEUR       PIC 99 VALUE 0.
       01 WS-MOYENNE        PIC 9(4)V99 VALUE 0.
       01 WS-TOTAL          PIC 9(4)V99 VALUE 0.
       
       PROCEDURE DIVISION.
           OPEN INPUT FICHIER-NOTE
           
           DISPLAY " "
           DISPLAY "=== LISTE DES NOTES ==="
           DISPLAY "ID     ETUDIANT     COURS              NOTE   DATE"
           DISPLAY "---------------------------------------------------"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-NOTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COMPTEUR
                       ADD VALEUR-NOTE TO WS-TOTAL
                       DISPLAY ID-NOTE " " ID-ETU-NOTE "   " 
                               ID-COURS-NOTE "        " VALEUR-NOTE "   " DATE-NOTE
               END-READ
           END-PERFORM
           
           COMPUTE WS-MOYENNE = WS-TOTAL / WS-COMPTEUR
           
           DISPLAY "---------------------------------------------------"
           DISPLAY "TOTAL NOTES: " WS-COMPTEUR
           DISPLAY "MOYENNE GENERALE: " WS-MOYENNE "/20"
           
           CLOSE FICHIER-NOTE
           
           STOP RUN.
