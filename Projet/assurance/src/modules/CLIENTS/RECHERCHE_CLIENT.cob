       IDENTIFICATION DIVISION.
       PROGRAM-ID. RECHERCHE-CLIENT.
       
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
       01 WS-RECHERCHE       PIC X(6).
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-TROUVE          PIC X VALUE 'N'.
       
       PROCEDURE DIVISION.
           DISPLAY "=== RECHERCHE CLIENT ==="
           DISPLAY " "
           DISPLAY "ID a rechercher : "
           ACCEPT WS-RECHERCHE
           
           OPEN INPUT FICHIER-CLIENT
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CLIENT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-CLI = WS-RECHERCHE
                           MOVE 'Y' TO WS-TROUVE
                           DISPLAY " "
                           DISPLAY "--- CLIENT TROUVE ---"
                           DISPLAY "ID       : " ID-CLI
                           DISPLAY "NOM      : " NOM-CLI
                           DISPLAY "PRENOM   : " PRENOM-CLI
                           DISPLAY "ADRESSE  : " ADRESSE-CLI
                           DISPLAY "TELEPHONE: " TEL-CLI
                       END-IF
               END-READ
           END-PERFORM
           
           IF WS-TROUVE = 'N'
               DISPLAY "Client non trouve"
           END-IF
           
           CLOSE FICHIER-CLIENT
           
           STOP RUN.
