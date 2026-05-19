       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-LIVRES.
       
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
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-COMPTEUR       PIC 99 VALUE 0.
       
       PROCEDURE DIVISION.
           OPEN INPUT FICHIER-LIVRE
           
           DISPLAY " "
           DISPLAY "=== LISTE DES LIVRES ==="
           DISPLAY "ISBN               TITRE                          AUTEUR               CATEGORIE     QTE"
           DISPLAY "---------------------------------------------------------------------------------------"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-LIVRE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COMPTEUR
                       DISPLAY ISBN-LIV " " TITRE-LIV " " AUTEUR-LIV " " CAT-LIV "    " QTE-LIV
               END-READ
           END-PERFORM
           
           DISPLAY "---------------------------------------------------------------------------------------"
           DISPLAY "TOTAL LIVRES: " WS-COMPTEUR
           
           CLOSE FICHIER-LIVRE
           
           STOP RUN.
