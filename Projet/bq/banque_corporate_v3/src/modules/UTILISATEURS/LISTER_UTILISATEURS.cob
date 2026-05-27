       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-UTILISATEURS.
       
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
       01 WS-FIN           PIC X VALUE 'N'.
       01 WS-COUNT         PIC 9(4) VALUE 0.
       
       PROCEDURE DIVISION.
           DISPLAY "=== LISTE DES UTILISATEURS ==="
           DISPLAY " "
           
           OPEN INPUT FICHIER-USER
           MOVE 'N' TO WS-FIN
           MOVE 0 TO WS-COUNT
           
           DISPLAY "ID   ROLE       LOGIN           NOM                      AGENCE STATUT"
           DISPLAY "---- ---------- --------------- ------------------------ ------ ------"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-USER
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COUNT
                       DISPLAY ID-USER " "
                               ROLE-USER " "
                               LOGIN-USER " "
                               NOM-USER(1:24) " "
                               ID-AGENCE-USER " "
                               STATUT-USER
               END-READ
           END-PERFORM
           CLOSE FICHIER-USER
           
           DISPLAY " "
           DISPLAY "Total utilisateurs: " WS-COUNT
           
           STOP RUN.
