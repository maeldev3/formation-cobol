       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-COMPTES.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-COMPTE ASSIGN TO 'data/input/COMPTES.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-COMPTE.
       01 ENR-COMPTE.
          05 NUM-COMPTE      PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-CLI-COMPTE   PIC X(6).
          05 FILLER          PIC X(1).
          05 TYPE-COMPTE     PIC X(10).
          05 FILLER          PIC X(1).
          05 SOLDE-COMPTE    PIC 9(10)V99.
          05 FILLER          PIC X(1).
          05 DECOUVERT       PIC 9(10)V99.
          05 FILLER          PIC X(1).
          05 DATE-OUV        PIC X(10).
          05 FILLER          PIC X(1).
          05 STATUT-COMPTE   PIC X(6).
       
       WORKING-STORAGE SECTION.
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-COUNT          PIC 9(6) VALUE 0.
       01 WS-SOLDE-EDIT     PIC Z(9)9.99.
       01 WS-TOTAL-SOLDES   PIC 9(15)V99 VALUE 0.
       01 WS-TOTAL-EDIT     PIC Z(9)9.99.
       
       PROCEDURE DIVISION.
           DISPLAY "=== LISTE DES COMPTES ==="
           DISPLAY " "
           
           OPEN INPUT FICHIER-COMPTE
           MOVE 'N' TO WS-FIN
           MOVE 0 TO WS-COUNT
           MOVE 0 TO WS-TOTAL-SOLDES
           
           DISPLAY "NUMERO  TYPE       SOLDE          DATE OUV   STATUT"
           DISPLAY "------  ---------- -------------  ---------- ------"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-COMPTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COUNT
                       ADD SOLDE-COMPTE TO WS-TOTAL-SOLDES
                       MOVE SOLDE-COMPTE TO WS-SOLDE-EDIT
                       DISPLAY NUM-COMPTE "  " 
                               TYPE-COMPTE "  "
                               WS-SOLDE-EDIT "  "
                               DATE-OUV "  "
                               STATUT-COMPTE
               END-READ
           END-PERFORM
           CLOSE FICHIER-COMPTE
           
           DISPLAY " "
           DISPLAY "Total comptes: " WS-COUNT
           MOVE WS-TOTAL-SOLDES TO WS-TOTAL-EDIT
           DISPLAY "Total encours: " WS-TOTAL-EDIT " €"
           
           STOP RUN.
