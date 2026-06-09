       IDENTIFICATION DIVISION.
       PROGRAM-ID. RECHERCHE-AGENCE.
       
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
       01 WS-ID            PIC X(4).
       01 WS-FIN           PIC X VALUE 'N'.
       01 WS-TROUVE        PIC X VALUE 'N'.
       01 WS-CAPITAL-EDIT  PIC Z(12)9.99.
       
       PROCEDURE DIVISION.
           DISPLAY "=== RECHERCHE AGENCE ==="
           DISPLAY " "
           DISPLAY "ID AGENCE: "
           ACCEPT WS-ID
           
           OPEN INPUT FICHIER-AGENCE
           MOVE 'N' TO WS-TROUVE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-AGENCE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-AGENCE = WS-ID
                           MOVE 'Y' TO WS-TROUVE
                           MOVE CAPITAL-AGENCE TO WS-CAPITAL-EDIT
                           DISPLAY " "
                           DISPLAY "=== DETAILS AGENCE ==="
                           DISPLAY "ID        : " ID-AGENCE
                           DISPLAY "NOM       : " NOM-AGENCE
                           DISPLAY "VILLE     : " VILLE-AGENCE
                           DISPLAY "CODE POSTAL: " CP-AGENCE
                           DISPLAY "TELEPHONE : " TEL-AGENCE
                           DISPLAY "EMAIL     : " EMAIL-AGENCE
                           DISPLAY "CAPITAL   : " WS-CAPITAL-EDIT " €"
                           DISPLAY "CREATION  : " DATE-CREATION
                           DISPLAY "STATUT    : " STATUT-AGENCE
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-AGENCE
           
           IF WS-TROUVE = 'N'
               DISPLAY "ERREUR: Agence non trouvee"
           END-IF
           
           STOP RUN.
