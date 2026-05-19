       IDENTIFICATION DIVISION.
       PROGRAM-ID. RECHERCHE-ADHERENT.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-ADHERENT ASSIGN TO 'data/input/ADHERENTS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-ADHERENT.
       01 ENR-ADHERENT.
          05 ID-ADH          PIC X(6).
          05 FILLER          PIC X(1).
          05 NOM-ADH         PIC X(15).
          05 FILLER          PIC X(1).
          05 PRENOM-ADH      PIC X(10).
          05 FILLER          PIC X(1).
          05 ADRESSE-ADH     PIC X(35).
          05 FILLER          PIC X(1).
          05 DATE-ADH        PIC X(10).
       
       WORKING-STORAGE SECTION.
       01 WS-RECHERCHE       PIC X(6).
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-TROUVE          PIC X VALUE 'N'.
       
       PROCEDURE DIVISION.
           DISPLAY "=== RECHERCHE ADHERENT ==="
           DISPLAY " "
           DISPLAY "ID a rechercher : "
           ACCEPT WS-RECHERCHE
           
           OPEN INPUT FICHIER-ADHERENT
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-ADHERENT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-ADH = WS-RECHERCHE
                           MOVE 'Y' TO WS-TROUVE
                           DISPLAY " "
                           DISPLAY "--- ADHERENT TROUVE ---"
                           DISPLAY "ID     : " ID-ADH
                           DISPLAY "NOM    : " NOM-ADH
                           DISPLAY "PRENOM : " PRENOM-ADH
                           DISPLAY "ADRESSE: " ADRESSE-ADH
                           DISPLAY "DATE   : " DATE-ADH
                       END-IF
               END-READ
           END-PERFORM
           
           IF WS-TROUVE = 'N'
               DISPLAY "Adherent non trouve"
           END-IF
           
           CLOSE FICHIER-ADHERENT
           
           STOP RUN.
