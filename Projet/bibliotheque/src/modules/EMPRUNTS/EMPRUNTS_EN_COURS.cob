       IDENTIFICATION DIVISION.
       PROGRAM-ID. EMPRUNTS-EN-COURS.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-EMPRUNT ASSIGN TO 'data/input/EMPRUNTS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-EMPRUNT.
       01 ENR-EMPRUNT.
          05 EMP-ID          PIC X(6).
          05 FILLER          PIC X(1).
          05 EMP-ID-ADH      PIC X(6).
          05 FILLER          PIC X(1).
          05 EMP-ISBN        PIC X(17).
          05 FILLER          PIC X(1).
          05 EMP-DATE        PIC X(10).
       
       WORKING-STORAGE SECTION.
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-COMPTEUR       PIC 99 VALUE 0.
       
       PROCEDURE DIVISION.
           OPEN INPUT FICHIER-EMPRUNT
           
           DISPLAY " "
           DISPLAY "=== EMPRUNTS EN COURS ==="
           DISPLAY "ID     ADHERENT     DATE EMPRUNT"
           DISPLAY "--------------------------------"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-EMPRUNT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COMPTEUR
                       DISPLAY EMP-ID " " EMP-ID-ADH "       " EMP-DATE
               END-READ
           END-PERFORM
           
           DISPLAY "--------------------------------"
           DISPLAY "TOTAL EMPRUNTS: " WS-COMPTEUR
           
           CLOSE FICHIER-EMPRUNT
           
           STOP RUN.
