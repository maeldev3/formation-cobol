       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUT-COMPTE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-COMPTE ASSIGN TO 'data/input/COMPTES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-CLIENT ASSIGN TO 'data/input/CLIENTS.DAT'
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
       
       FD FICHIER-CLIENT.
       01 ENR-CLIENT.
          05 ID-CLI          PIC X(6).
       
       WORKING-STORAGE SECTION.
       01 WS-NUM             PIC X(6).
       01 WS-ID-CLI          PIC X(6).
       01 WS-TYPE            PIC X(4).
       01 WS-SOLDE           PIC 9(9)V99.
       01 WS-DATE            PIC X(10).
       01 WS-COMPTEUR        PIC 99.
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-CLIENT-OK       PIC X VALUE 'N'.
       01 WS-EXISTE          PIC X VALUE 'N'.
       
       PROCEDURE DIVISION.
           DISPLAY "=== AJOUTER UN COMPTE ==="
           DISPLAY " "
           
           DISPLAY "ID CLIENT: "
           ACCEPT WS-ID-CLI
           DISPLAY "TYPE (COUR/EPAR): "
           ACCEPT WS-TYPE
           DISPLAY "SOLDE INITIAL: "
           ACCEPT WS-SOLDE
           
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
      *> Vérifier client
           OPEN INPUT FICHIER-CLIENT
           MOVE 'N' TO WS-CLIENT-OK
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CLIENT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-CLI = WS-ID-CLI
                           MOVE 'Y' TO WS-CLIENT-OK
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-CLIENT
           
           IF WS-CLIENT-OK = 'N'
               DISPLAY "ERREUR: Client inexistant"
               STOP RUN
           END-IF
           
      *> Générer numéro de compte
           OPEN INPUT FICHIER-COMPTE
           MOVE 1 TO WS-COMPTEUR
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               MOVE WS-COMPTEUR TO WS-NUM(5:2)
               MOVE 'C' TO WS-NUM(1:1)
               MOVE 'P' TO WS-NUM(2:1)
               MOVE 'T' TO WS-NUM(3:1)
               MOVE '0' TO WS-NUM(4:1)
               
               READ FICHIER-COMPTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF NUM-COMPTE = WS-NUM
                           ADD 1 TO WS-COMPTEUR
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-COMPTE
           
      *> Ajouter compte
           OPEN EXTEND FICHIER-COMPTE
           
           MOVE WS-NUM TO NUM-COMPTE
           MOVE WS-ID-CLI TO ID-CLIENT-C
           MOVE WS-TYPE TO TYPE-COMPTE
           MOVE WS-SOLDE TO SOLDE-COMPTE
           MOVE WS-DATE TO DATE-OUV-COMP
           
           WRITE ENR-COMPTE
           CLOSE FICHIER-COMPTE
           
           DISPLAY " "
           DISPLAY "--- COMPTE AJOUTE ---"
           DISPLAY "NUMERO      : " WS-NUM
           DISPLAY "CLIENT      : " WS-ID-CLI
           DISPLAY "TYPE        : " WS-TYPE
           DISPLAY "SOLDE       : " WS-SOLDE " €"
           DISPLAY "DATE        : " WS-DATE
           
           STOP RUN.
