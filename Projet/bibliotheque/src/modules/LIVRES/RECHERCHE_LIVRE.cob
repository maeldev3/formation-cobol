       IDENTIFICATION DIVISION.
       PROGRAM-ID. RECHERCHE-LIVRE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-LIVRE ASSIGN TO 'data/input/LIVRES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-LIVRE.
       01 ENR-LIVRE.
          05 ISBN-LIV       PIC X(17).
          05 FILLER         PIC X(1).
          05 TITRE-LIV      PIC X(30).
          05 FILLER         PIC X(1).
          05 AUTEUR-LIV     PIC X(20).
          05 FILLER         PIC X(1).
          05 CAT-LIV        PIC X(15).
          05 FILLER         PIC X(1).
          05 QTE-LIV        PIC 9(3).
       
       WORKING-STORAGE SECTION.
       01 WS-RECHERCHE      PIC X(17).
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-TROUVE         PIC X VALUE 'N'.
       
       PROCEDURE DIVISION.
           DISPLAY "=== RECHERCHE LIVRE ==="
           DISPLAY " "
           DISPLAY "ISBN a rechercher : "
           ACCEPT WS-RECHERCHE
           
           OPEN INPUT FICHIER-LIVRE
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-LIVRE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ISBN-LIV = WS-RECHERCHE
                           MOVE 'Y' TO WS-TROUVE
                           DISPLAY " "
                           DISPLAY "--- LIVRE TROUVE ---"
                           DISPLAY "ISBN     : " ISBN-LIV
                           DISPLAY "TITRE    : " TITRE-LIV
                           DISPLAY "AUTEUR   : " AUTEUR-LIV
                           DISPLAY "CATEGORIE: " CAT-LIV
                           DISPLAY "QUANTITE : " QTE-LIV
                       END-IF
               END-READ
           END-PERFORM
           
           IF WS-TROUVE = 'N'
               DISPLAY "Livre non trouve"
           END-IF
           
           CLOSE FICHIER-LIVRE
           
           STOP RUN.
