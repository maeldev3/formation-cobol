       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-ADHERENTS.
       
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
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-COMPTEUR       PIC 99 VALUE 0.
       
       PROCEDURE DIVISION.
           OPEN INPUT FICHIER-ADHERENT
           
           DISPLAY " "
           DISPLAY "=== LISTE DES ADHERENTS ==="
           DISPLAY "ID     NOM              PRENOM     DATE ADHESION"
           DISPLAY "----------------------------------------------"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-ADHERENT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COMPTEUR
                       DISPLAY ID-ADH " " NOM-ADH " " PRENOM-ADH "   " DATE-ADH
               END-READ
           END-PERFORM
           
           DISPLAY "----------------------------------------------"
           DISPLAY "TOTAL ADHERENTS: " WS-COMPTEUR
           
           CLOSE FICHIER-ADHERENT
           
           STOP RUN.
