       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUT-AGENCE.
       
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
       01 WS-NOM           PIC X(30).
       01 WS-VILLE         PIC X(20).
       01 WS-CP            PIC X(5).
       01 WS-TEL           PIC X(10).
       01 WS-EMAIL         PIC X(30).
       01 WS-CAPITAL       PIC 9(12)V99.
       01 WS-DATE          PIC X(10).
       01 WS-FIN           PIC X VALUE 'N'.
       01 WS-EXISTE        PIC X VALUE 'N'.
       01 WS-COUNT         PIC 9(4) VALUE 0.
       01 WS-CAPITAL-EDIT  PIC Z(12)9.99.
       
       PROCEDURE DIVISION.
           DISPLAY "=== AJOUT D'UNE AGENCE ==="
           DISPLAY " "
           
           DISPLAY "ID AGENCE (A007): "
           ACCEPT WS-ID
           DISPLAY "NOM AGENCE: "
           ACCEPT WS-NOM
           DISPLAY "VILLE: "
           ACCEPT WS-VILLE
           DISPLAY "CODE POSTAL: "
           ACCEPT WS-CP
           DISPLAY "TELEPHONE: "
           ACCEPT WS-TEL
           DISPLAY "EMAIL: "
           ACCEPT WS-EMAIL
           DISPLAY "CAPITAL: "
           ACCEPT WS-CAPITAL
           
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
      *> Verification existence
           OPEN INPUT FICHIER-AGENCE
           MOVE 'N' TO WS-EXISTE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-AGENCE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-AGENCE = WS-ID
                           MOVE 'Y' TO WS-EXISTE
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-AGENCE
           
           IF WS-EXISTE = 'Y'
               DISPLAY "ERREUR: ID Agence existe deja"
               STOP RUN
           END-IF
           
      *> Ajout agence
           OPEN EXTEND FICHIER-AGENCE
           
           MOVE WS-ID TO ID-AGENCE
           MOVE WS-NOM TO NOM-AGENCE
           MOVE WS-VILLE TO VILLE-AGENCE
           MOVE WS-CP TO CP-AGENCE
           MOVE WS-TEL TO TEL-AGENCE
           MOVE WS-EMAIL TO EMAIL-AGENCE
           MOVE WS-CAPITAL TO CAPITAL-AGENCE
           MOVE WS-DATE TO DATE-CREATION
           MOVE "ACTIF" TO STATUT-AGENCE
           
           WRITE ENR-AGENCE
           CLOSE FICHIER-AGENCE
           
           MOVE WS-CAPITAL TO WS-CAPITAL-EDIT
           
           DISPLAY " "
           DISPLAY "--- AGENCE AJOUTEE AVEC SUCCES ---"
           DISPLAY "ID      : " WS-ID
           DISPLAY "NOM     : " WS-NOM
           DISPLAY "VILLE   : " WS-VILLE
           DISPLAY "CAPITAL : " WS-CAPITAL-EDIT " €"
           DISPLAY "DATE    : " WS-DATE
           
           STOP RUN.
