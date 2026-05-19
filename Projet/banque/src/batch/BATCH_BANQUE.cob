       IDENTIFICATION DIVISION.
       PROGRAM-ID. BATCH-BANQUE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-COMPTE ASSIGN TO 'data/input/COMPTES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-EPARGNE ASSIGN TO 'data/input/COMPTES.TMP'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-RAPPORT ASSIGN TO 'data/output/reports/RAPPORT_BANQUE.rpt'
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
       
       FD FICHIER-EPARGNE.
       01 ENR-EPARGNE       PIC X(80).
       
       FD FICHIER-RAPPORT.
       01 ENR-RAPPORT       PIC X(80).
       
       WORKING-STORAGE SECTION.
       01 WS-DATE            PIC X(10).
       01 WS-TOTAL-EPARGNE   PIC 9(12)V99 VALUE 0.
       01 WS-TOTAL-COURANT   PIC 9(12)V99 VALUE 0.
       01 WS-NB-COMPTES      PIC 99 VALUE 0.
       01 WS-INTERETS        PIC 9(9)V99.
       01 WS-NOUV-SOLDE      PIC 9(9)V99.
       01 WS-FIN             PIC X VALUE 'N'.
       
       PROCEDURE DIVISION.
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
           OPEN INPUT FICHIER-COMPTE
           OPEN OUTPUT FICHIER-EPARGNE
           OPEN OUTPUT FICHIER-RAPPORT
           
      *> En-tête rapport
           STRING "RAPPORT MENSUEL BANQUE - " WS-DATE
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           MOVE SPACES TO ENR-RAPPORT
           STRING "================================="
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
      *> Calculer intérêts épargne (2% annuel = 0.1667% mensuel)
           MOVE 'N' TO WS-FIN
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-COMPTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-NB-COMPTES
                       IF TYPE-COMPTE = 'EPAR'
                           COMPUTE WS-INTERETS = 
                               SOLDE-COMPTE * 0.001667
                           COMPUTE WS-NOUV-SOLDE = 
                               SOLDE-COMPTE + WS-INTERETS
                           ADD SOLDE-COMPTE TO WS-TOTAL-EPARGNE
                           MOVE SPACES TO ENR-RAPPORT
                           STRING "Compte epargne " NUM-COMPTE 
                                   ": interets " WS-INTERETS " €"
                               INTO ENR-RAPPORT
                           WRITE ENR-RAPPORT
                       ELSE
                           ADD SOLDE-COMPTE TO WS-TOTAL-COURANT
                       END-IF
                       MOVE ENR-COMPTE TO ENR-EPARGNE
                       WRITE ENR-EPARGNE
               END-READ
           END-PERFORM
           
      *> Totaux
           MOVE SPACES TO ENR-RAPPORT
           STRING "Total comptes courants: " WS-TOTAL-COURANT " €"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           MOVE SPACES TO ENR-RAPPORT
           STRING "Total comptes epargne: " WS-TOTAL-EPARGNE " €"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           MOVE SPACES TO ENR-RAPPORT
           STRING "Nombre total de comptes: " WS-NB-COMPTES
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           CLOSE FICHIER-COMPTE, FICHIER-EPARGNE, FICHIER-RAPPORT
           
           DISPLAY " "
           DISPLAY "=== BATCH BANQUE TERMINE ==="
           DISPLAY "Comptes courants: " WS-TOTAL-COURANT " €"
           DISPLAY "Comptes epargne: " WS-TOTAL-EPARGNE " €"
           DISPLAY "Rapport: data/output/reports/RAPPORT_BANQUE.rpt"
           
           STOP RUN.
