       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUT-UTILISATEUR.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-USER ASSIGN TO 'data/input/UTILISATEURS.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-AGENCE ASSIGN TO 'data/input/AGENCES.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-USER.
       01 ENR-USER.
          05 ID-USER        PIC X(4).
          05 FILLER         PIC X(1).
          05 ROLE-USER      PIC X(10).
          05 FILLER         PIC X(1).
          05 LOGIN-USER     PIC X(15).
          05 FILLER         PIC X(1).
          05 PASSWORD-USER  PIC X(20).
          05 FILLER         PIC X(1).
          05 NOM-USER       PIC X(30).
          05 FILLER         PIC X(1).
          05 EMAIL-USER     PIC X(30).
          05 FILLER         PIC X(1).
          05 DATE-EMBAUCHE  PIC X(10).
          05 FILLER         PIC X(1).
          05 STATUT-USER    PIC X(6).
          05 FILLER         PIC X(1).
          05 ID-AGENCE-USER PIC X(4).
       
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
       01 WS-ROLE          PIC X(10).
       01 WS-LOGIN         PIC X(15).
       01 WS-PASSWORD      PIC X(20).
       01 WS-NOM           PIC X(30).
       01 WS-EMAIL         PIC X(30).
       01 WS-DATE          PIC X(10).
       01 WS-ID-AGENCE     PIC X(4).
       01 WS-FIN           PIC X VALUE 'N'.
       01 WS-EXISTE        PIC X VALUE 'N'.
       01 WS-AGENCE-EXISTE PIC X VALUE 'N'.
       01 WS-COUNT         PIC 9(4) VALUE 0.
       
       PROCEDURE DIVISION.
           DISPLAY "=== AJOUT D'UN UTILISATEUR ==="
           DISPLAY " "
           
           DISPLAY "ROLE (ADMIN/AGENT/MANAGER/AUDITEUR): "
           ACCEPT WS-ROLE
           DISPLAY "LOGIN: "
           ACCEPT WS-LOGIN
           DISPLAY "PASSWORD: "
           ACCEPT WS-PASSWORD
           DISPLAY "NOM COMPLET: "
           ACCEPT WS-NOM
           DISPLAY "EMAIL: "
           ACCEPT WS-EMAIL
           DISPLAY "ID AGENCE: "
           ACCEPT WS-ID-AGENCE
           
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
      *> Verifier agence
           OPEN INPUT FICHIER-AGENCE
           MOVE 'N' TO WS-AGENCE-EXISTE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-AGENCE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-AGENCE = WS-ID-AGENCE
                           MOVE 'Y' TO WS-AGENCE-EXISTE
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-AGENCE
           
           IF WS-AGENCE-EXISTE = 'N'
               DISPLAY "ERREUR: Agence inexistante"
               STOP RUN
           END-IF
           
      *> Verification existence
           OPEN INPUT FICHIER-USER
           MOVE 'N' TO WS-EXISTE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-USER
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF LOGIN-USER = WS-LOGIN
                           MOVE 'Y' TO WS-EXISTE
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-USER
           
           IF WS-EXISTE = 'Y'
               DISPLAY "ERREUR: Login existe deja"
               STOP RUN
           END-IF
           
      *> Generer ID utilisateur
           OPEN INPUT FICHIER-USER
           MOVE 0 TO WS-COUNT
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-USER
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COUNT
               END-READ
           END-PERFORM
           CLOSE FICHIER-USER
           
           ADD 1 TO WS-COUNT
           STRING 'U' WS-COUNT(1:3) INTO WS-ID
           
      *> Ajout utilisateur
           OPEN EXTEND FICHIER-USER
           
           MOVE WS-ID TO ID-USER
           MOVE WS-ROLE TO ROLE-USER
           MOVE WS-LOGIN TO LOGIN-USER
           MOVE WS-PASSWORD TO PASSWORD-USER
           MOVE WS-NOM TO NOM-USER
           MOVE WS-EMAIL TO EMAIL-USER
           MOVE WS-DATE TO DATE-EMBAUCHE
           MOVE "ACTIF" TO STATUT-USER
           MOVE WS-ID-AGENCE TO ID-AGENCE-USER
           
           WRITE ENR-USER
           CLOSE FICHIER-USER
           
           DISPLAY " "
           DISPLAY "--- UTILISATEUR AJOUTE AVEC SUCCES ---"
           DISPLAY "ID      : " WS-ID
           DISPLAY "ROLE    : " WS-ROLE
           DISPLAY "LOGIN   : " WS-LOGIN
           DISPLAY "NOM     : " WS-NOM
           DISPLAY "AGENCE  : " WS-ID-AGENCE
           DISPLAY "DATE    : " WS-DATE
           
           STOP RUN.
