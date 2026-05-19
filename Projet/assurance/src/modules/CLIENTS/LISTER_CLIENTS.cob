       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-CLIENTS.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CLIENT ASSIGN TO 'data/input/CLIENTS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-CLIENT.
       01 ENR-CLIENT.
          05 ID-CLI          PIC X(6).
          05 FILLER          PIC X(1).
          05 NOM-CLI         PIC X(15).
          05 FILLER          PIC X(1).
          05 PRENOM-CLI      PIC X(10).
          05 FILLER          PIC X(1).
          05 ADRESSE-CLI     PIC X(35).
          05 FILLER          PIC X(1).
          05 TEL-CLI         PIC X(10).
       
       WORKING-STORAGE SECTION.
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-COMPTEUR       PIC 99 VALUE 0.
       
       PROCEDURE DIVISION.
           OPEN INPUT FICHIER-CLIENT
           
           DISPLAY " "
           DISPLAY "=== LISTE DES CLIENTS ==="
           DISPLAY "ID     NOM              PRENOM     TELEPHONE"
           DISPLAY "--------------------------------------------"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CLIENT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COMPTEUR
                       DISPLAY ID-CLI " " NOM-CLI " " PRENOM-CLI "   " TEL-CLI
               END-READ
           END-PERFORM
           
           DISPLAY "--------------------------------------------"
           DISPLAY "TOTAL CLIENTS: " WS-COMPTEUR
           
           CLOSE FICHIER-CLIENT
           
           STOP RUN.
