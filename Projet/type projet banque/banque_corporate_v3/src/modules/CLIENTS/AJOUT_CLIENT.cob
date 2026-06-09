       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUT-CLIENT.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CLIENT ASSIGN TO 'data/input/CLIENTS.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-TEMP ASSIGN TO 'data/temp/CLIENTS.TMP'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-CLIENT.
       01 ENR-CLIENT.
          05 ID-CLIENT       PIC X(6).
          05 FILLER          PIC X(1).
          05 NOM-CLIENT      PIC X(20).
          05 FILLER          PIC X(1).
          05 PRENOM-CLIENT   PIC X(15).
          05 FILLER          PIC X(1).
          05 ADRESSE-CLIENT  PIC X(35).
          05 FILLER          PIC X(1).
          05 CP-CLIENT       PIC X(5).
          05 FILLER          PIC X(1).
          05 VILLE-CLIENT    PIC X(20).
          05 FILLER          PIC X(1).
          05 TEL-CLIENT      PIC X(10).
          05 FILLER          PIC X(1).
          05 EMAIL-CLIENT    PIC X(30).
          05 FILLER          PIC X(1).
          05 REVENU-CLIENT   PIC 9(8)V99.
          05 FILLER          PIC X(1).
          05 DATE-OUVERTURE  PIC X(10).
          05 FILLER          PIC X(1).
          05 STATUT-CLIENT   PIC X(7).
          05 FILLER          PIC X(1).
          05 CATEGORIE       PIC X(10).
       
       FD FICHIER-TEMP.
       01 ENR-TEMP          PIC X(150).
       
       WORKING-STORAGE SECTION.
       01 WS-ID             PIC X(6).
       01 WS-NOM            PIC X(20).
       01 WS-PRENOM         PIC X(15).
       01 WS-ADRESSE        PIC X(35).
       01 WS-CP             PIC X(5).
       01 WS-VILLE          PIC X(20).
       01 WS-TEL            PIC X(10).
       01 WS-EMAIL          PIC X(30).
       01 WS-REVENU         PIC 9(8)V99.
       01 WS-DATE           PIC X(10).
       01 WS-CATEG          PIC X(10).
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-EXISTE         PIC X VALUE 'N'.
       01 WS-REVENU-EDIT    PIC Z(8)9.99.
       
       PROCEDURE DIVISION.
           DISPLAY "=== AJOUT D'UN NOUVEAU CLIENT ==="
           DISPLAY " "
           
           DISPLAY "ID CLIENT (C00001): "
           ACCEPT WS-ID
           DISPLAY "NOM: "
           ACCEPT WS-NOM
           DISPLAY "PRENOM: "
           ACCEPT WS-PRENOM
           DISPLAY "ADRESSE: "
           ACCEPT WS-ADRESSE
           DISPLAY "CODE POSTAL: "
           ACCEPT WS-CP
           DISPLAY "VILLE: "
           ACCEPT WS-VILLE
           DISPLAY "TELEPHONE: "
           ACCEPT WS-TEL
           DISPLAY "EMAIL: "
           ACCEPT WS-EMAIL
           DISPLAY "REVENU ANNUEL: "
           ACCEPT WS-REVENU
           
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
           IF WS-REVENU > 100000
               MOVE "GOLD" TO WS-CATEG
           ELSE
               IF WS-REVENU > 70000
                   MOVE "PREMIUM" TO WS-CATEG
               ELSE
                   MOVE "CLASSIC" TO WS-CATEG
               END-IF
           END-IF
           
      *> Verification existence
           OPEN INPUT FICHIER-CLIENT
           MOVE 'N' TO WS-EXISTE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CLIENT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-CLIENT = WS-ID
                           MOVE 'Y' TO WS-EXISTE
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-CLIENT
           
           IF WS-EXISTE = 'Y'
               DISPLAY "ERREUR: ID client existe deja"
               STOP RUN
           END-IF
           
      *> Ajout du client
           OPEN EXTEND FICHIER-CLIENT
           
           MOVE WS-ID TO ID-CLIENT
           MOVE WS-NOM TO NOM-CLIENT
           MOVE WS-PRENOM TO PRENOM-CLIENT
           MOVE WS-ADRESSE TO ADRESSE-CLIENT
           MOVE WS-CP TO CP-CLIENT
           MOVE WS-VILLE TO VILLE-CLIENT
           MOVE WS-TEL TO TEL-CLIENT
           MOVE WS-EMAIL TO EMAIL-CLIENT
           MOVE WS-REVENU TO REVENU-CLIENT
           MOVE WS-DATE TO DATE-OUVERTURE
           MOVE "ACTIF" TO STATUT-CLIENT
           MOVE WS-CATEG TO CATEGORIE
           
           WRITE ENR-CLIENT
           CLOSE FICHIER-CLIENT
           
           MOVE WS-REVENU TO WS-REVENU-EDIT
           
           DISPLAY " "
           DISPLAY "--- CLIENT AJOUTE AVEC SUCCES ---"
           DISPLAY "ID       : " WS-ID
           DISPLAY "NOM      : " WS-NOM
           DISPLAY "PRENOM   : " WS-PRENOM
           DISPLAY "CATEGORIE: " WS-CATEG
           DISPLAY "REVENU   : " WS-REVENU-EDIT " €"
           DISPLAY "DATE     : " WS-DATE
           
           STOP RUN.
