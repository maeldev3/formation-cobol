       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUT-CLIENT.
       
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
       01 WS-NEW-ID          PIC X(6).
       01 WS-NEW-NOM         PIC X(15).
       01 WS-NEW-PRENOM      PIC X(10).
       01 WS-NEW-ADRESSE     PIC X(35).
       01 WS-NEW-TEL         PIC X(10).
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-EXISTE          PIC X VALUE 'N'.
       
       PROCEDURE DIVISION.
           DISPLAY "=== AJOUTER UN CLIENT ==="
           DISPLAY " "
           
           DISPLAY "ID (C00007) : "
           ACCEPT WS-NEW-ID
           DISPLAY "NOM : "
           ACCEPT WS-NEW-NOM
           DISPLAY "PRENOM : "
           ACCEPT WS-NEW-PRENOM
           DISPLAY "ADRESSE : "
           ACCEPT WS-NEW-ADRESSE
           DISPLAY "TELEPHONE : "
           ACCEPT WS-NEW-TEL
           
      *> Vérifier si l'ID existe
           OPEN INPUT FICHIER-CLIENT
           MOVE 'N' TO WS-EXISTE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CLIENT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-CLI = WS-NEW-ID
                           MOVE 'Y' TO WS-EXISTE
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-CLIENT
           
           IF WS-EXISTE = 'Y'
               DISPLAY "ERREUR: ID existe deja"
               STOP RUN
           END-IF
           
      *> Ajouter le client
           OPEN EXTEND FICHIER-CLIENT
           
           MOVE WS-NEW-ID TO ID-CLI
           MOVE WS-NEW-NOM TO NOM-CLI
           MOVE WS-NEW-PRENOM TO PRENOM-CLI
           MOVE WS-NEW-ADRESSE TO ADRESSE-CLI
           MOVE WS-NEW-TEL TO TEL-CLI
           
           WRITE ENR-CLIENT
           CLOSE FICHIER-CLIENT
           
           DISPLAY " "
           DISPLAY "--- NOUVEAU CLIENT AJOUTE ---"
           DISPLAY "ID       : " WS-NEW-ID
           DISPLAY "NOM      : " WS-NEW-NOM
           DISPLAY "PRENOM   : " WS-NEW-PRENOM
           DISPLAY "ADRESSE  : " WS-NEW-ADRESSE
           DISPLAY "TELEPHONE: " WS-NEW-TEL
           
           STOP RUN.
