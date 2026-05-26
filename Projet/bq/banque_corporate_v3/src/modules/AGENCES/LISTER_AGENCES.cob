       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-AGENCES.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-AGENCE ASSIGN TO 'data/input/AGENCES.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-AGENCE.
       01 ENR-AGENCE.
          05 ID-AGENCE      PIC X(4).
          05 FILLER         PIC X(1).
          05 NOM-AGENCE     PIC X(30).
          05 FILLER         PIC X(1).
          05 VILLE-AGENCE   PIC X(20).
          05 FILLER         PIC X(1).
          05 CP-AGENCE      PIC X(5).
          05 FILLER         PIC X(1).
          05 TEL-AGENCE     PIC X(10).
          05 FILLER         PIC X(1).
          05 EMAIL-AGENCE   PIC X(30).
          05 FILLER         PIC X(1).
          05 CAPITAL-AGENCE PIC 9(12)V99.
          05 FILLER         PIC X(1).
          05 DATE-CREATION  PIC X(10).
          05 FILLER         PIC X(1).
          05 STATUT-AGENCE  PIC X(6).
       
       WORKING-STORAGE SECTION.
       01 WS-FIN           PIC X VALUE 'N'.
       01 WS-COUNT         PIC 9(4) VALUE 0.
       01 WS-TOTAL-CAPITAL PIC 9(15)V99 VALUE 0.
       01 WS-CAPITAL-EDIT  PIC Z(12)9.99.
       01 WS-TOTAL-EDIT    PIC Z(12)9.99.
       
       PROCEDURE DIVISION.
           DISPLAY "=== LISTE DES AGENCES ==="
           DISPLAY " "
           
           OPEN INPUT FICHIER-AGENCE
           MOVE 'N' TO WS-FIN
           MOVE 0 TO WS-COUNT
           MOVE 0 TO WS-TOTAL-CAPITAL
           
           DISPLAY "ID   NOM                           VILLE               CAPITAL        STATUT"
           DISPLAY "---- ------------------------------ ------------------- -------------- ------"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-AGENCE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COUNT
                       ADD CAPITAL-AGENCE TO WS-TOTAL-CAPITAL
                       MOVE CAPITAL-AGENCE TO WS-CAPITAL-EDIT
                       DISPLAY ID-AGENCE "  " 
                               NOM-AGENCE(1:30) " "
                               VILLE-AGENCE(1:20) " "
                               WS-CAPITAL-EDIT " "
                               STATUT-AGENCE
               END-READ
           END-PERFORM
           CLOSE FICHIER-AGENCE
           
           DISPLAY " "
           DISPLAY "Total agences: " WS-COUNT
           MOVE WS-TOTAL-CAPITAL TO WS-TOTAL-EDIT
           DISPLAY "Capital total: " WS-TOTAL-EDIT " €"
           
           STOP RUN.
