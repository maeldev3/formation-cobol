       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-COMPTES.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-COMPTE ASSIGN TO 'data/input/COMPTES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-COMPTE.
       01 ENR-COMPTE.
          05 NUM-COMPTE      PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-CLIENT-C     PIC X(6).
          05 FILLER          PIC X(1).
          05 TYPE-COMPTE     PIC X(4).
          05 FILLER          PIC X(1).
          05 SOLDE-COMPTE    PIC 9(9)V99.
          05 FILLER          PIC X(1).
          05 DATE-OUV-COMP   PIC X(10).
       
       WORKING-STORAGE SECTION.
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-COMPTEUR       PIC 99 VALUE 0.
       01 WS-TOTAL-SOLDES   PIC 9(12)V99 VALUE 0.
       
       PROCEDURE DIVISION.
           OPEN INPUT FICHIER-COMPTE
           
           DISPLAY " "
           DISPLAY "=== LISTE DES COMPTES ==="
           DISPLAY "NUMERO  CLIENT  TYPE  SOLDE        DATE OUV"
           DISPLAY "---------------------------------------------"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-COMPTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COMPTEUR
                       ADD SOLDE-COMPTE TO WS-TOTAL-SOLDES
                       DISPLAY NUM-COMPTE " " ID-CLIENT-C "   "
                               TYPE-COMPTE "   " SOLDE-COMPTE " €  "
                               DATE-OUV-COMP
               END-READ
           END-PERFORM
           
           DISPLAY "---------------------------------------------"
           DISPLAY "TOTAL COMPTES: " WS-COMPTEUR
           DISPLAY "TOTAL SOLDES: " WS-TOTAL-SOLDES " €"
           
           CLOSE FICHIER-COMPTE
           
           STOP RUN.
