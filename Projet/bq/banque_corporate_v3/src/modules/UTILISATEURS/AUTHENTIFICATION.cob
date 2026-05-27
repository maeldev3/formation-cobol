       IDENTIFICATION DIVISION.
       PROGRAM-ID. AUTHENTIFICATION.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-USER ASSIGN TO 'data/input/UTILISATEURS.dat'
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
       
       WORKING-STORAGE SECTION.
       01 WS-LOGIN         PIC X(15).
       01 WS-PASSWORD      PIC X(20).
       01 WS-FIN           PIC X VALUE 'N'.
       01 WS-AUTHENTIFIE   PIC X VALUE 'N'.
       01 WS-ROLE          PIC X(10).
       01 WS-NOM           PIC X(30).
       01 WS-AGENCE        PIC X(4).
       
       PROCEDURE DIVISION.
           DISPLAY "=== AUTHENTIFICATION ==="
           DISPLAY " "
           DISPLAY "LOGIN: "
           ACCEPT WS-LOGIN
           DISPLAY "PASSWORD: "
           ACCEPT WS-PASSWORD
           
           OPEN INPUT FICHIER-USER
           MOVE 'N' TO WS-AUTHENTIFIE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-USER
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF LOGIN-USER = WS-LOGIN AND
                          PASSWORD-USER = WS-PASSWORD AND
                          STATUT-USER = "ACTIF"
                           MOVE 'Y' TO WS-AUTHENTIFIE
                           MOVE ROLE-USER TO WS-ROLE
                           MOVE NOM-USER TO WS-NOM
                           MOVE ID-AGENCE-USER TO WS-AGENCE
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-USER
           
           IF WS-AUTHENTIFIE = 'Y'
               DISPLAY " "
               DISPLAY "--- AUTHENTIFICATION REUSSIE ---"
               DISPLAY "Bienvenue " WS-NOM
               DISPLAY "Role: " WS-ROLE
               DISPLAY "Agence: " WS-AGENCE
               DISPLAY "Date: " FUNCTION CURRENT-DATE
           ELSE
               DISPLAY "ERREUR: Login ou mot de passe incorrect"
           END-IF
           
           STOP RUN.
