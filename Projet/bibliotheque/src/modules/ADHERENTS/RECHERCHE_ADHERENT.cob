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
       01 WS-RECHERCHE-ID    PIC X(6).
       01 WS-TROUVE         PIC X VALUE 'N'.
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-AGE            PIC 99.
       01 WS-PRIME          PIC 9(5)V99.
       
       PROCEDURE DIVISION.
           DISPLAY " "
           DISPLAY "================= RECHERCHE ADHERENT ================="
           DISPLAY "ID a rechercher : "
           ACCEPT WS-RECHERCHE-ID
           
           OPEN INPUT FICHIER-ADHERENT
           MOVE 'N' TO WS-TROUVE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y' OR WS-TROUVE = 'Y'
               READ FICHIER-ADHERENT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-ADH = WS-RECHERCHE-ID
                           MOVE 'Y' TO WS-TROUVE
                           PERFORM CALCUL-AGE-PRIME
                           PERFORM AFFICHER-ADHERENT
                       END-IF
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-ADHERENT
           
           IF WS-TROUVE = 'N'
               DISPLAY " "
               DISPLAY "*** ADHERENT NON TROUVE ***"
           END-IF.
           
           STOP RUN.
       
       CALCUL-AGE-PRIME.
           *> Calcul de l'âge à partir de DATE-ADH
           COMPUTE WS-AGE = FUNCTION INTEGER(FUNCTION SUBSTITUTE(DATE-ADH(1:4),'20','')) 
           
           IF WS-AGE < 25
               COMPUTE WS-PRIME = 50.00
           ELSE
               IF WS-AGE < 60
                   COMPUTE WS-PRIME = 80.00
               ELSE
                   COMPUTE WS-PRIME = 100.00
               END-IF
           END-IF.
       
       AFFICHER-ADHERENT.
           DISPLAY " "
           DISPLAY "------------------ ADHERENT TROUVE ------------------"
           DISPLAY "ID      : " ID-ADH
           DISPLAY "NOM     : " FUNCTION TRIM(NOM-ADH)
           DISPLAY "PRENOM  : " FUNCTION TRIM(PRENOM-ADH)
           DISPLAY "ADRESSE : " FUNCTION TRIM(ADRESSE-ADH)
           DISPLAY "DATE    : " DATE-ADH
           DISPLAY "AGE     : " WS-AGE " ans"
           DISPLAY "PRIME   : " WS-PRIME " €"
           DISPLAY "------------------------------------------------------".