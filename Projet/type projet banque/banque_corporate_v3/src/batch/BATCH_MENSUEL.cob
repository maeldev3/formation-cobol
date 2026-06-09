       IDENTIFICATION DIVISION.
       PROGRAM-ID. BATCH-MENSUEL.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-COMPTE ASSIGN TO 'data/input/COMPTES.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-TRANSACTION ASSIGN TO 'data/input/TRANSACTIONS.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-RAPPORT ASSIGN TO 
               'data/output/reports/RAPPORT_MENSUEL.rpt'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-TEMP ASSIGN TO 'data/temp/COMPTES.TMP'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-COMPTE.
       01 ENR-COMPTE.
          05 NUM-COMPTE     PIC X(6).
          05 FILLER         PIC X(1).
          05 ID-CLI-COMPTE  PIC X(6).
          05 FILLER         PIC X(1).
          05 TYPE-COMPTE    PIC X(10).
          05 FILLER         PIC X(1).
          05 SOLDE-COMPTE   PIC 9(10)V99.
          05 FILLER         PIC X(1).
          05 DECOUVERT      PIC 9(10)V99.
          05 FILLER         PIC X(1).
          05 DATE-OUV       PIC X(10).
          05 FILLER         PIC X(1).
          05 STATUT-COMPTE  PIC X(6).
       
       FD FICHIER-TRANSACTION.
       01 ENR-TRANS.
          05 ID-TRANS       PIC X(15).
          05 FILLER         PIC X(1).
          05 NUM-COMPTE-T   PIC X(6).
          05 FILLER         PIC X(1).
          05 DATE-TRANS     PIC X(10).
          05 FILLER         PIC X(1).
          05 MONTANT-TRANS  PIC 9(10)V99.
          05 FILLER         PIC X(1).
          05 TYPE-TRANS     PIC X(15).
          05 FILLER         PIC X(1).
          05 MODE-TRANS     PIC X(10).
          05 FILLER         PIC X(1).
          05 STATUT-TRANS   PIC X(7).
       
       FD FICHIER-RAPPORT.
       01 ENR-RAPPORT      PIC X(80).
       
       FD FICHIER-TEMP.
       01 ENR-TEMP         PIC X(80).
       
       WORKING-STORAGE SECTION.
       01 WS-MOIS          PIC X(2).
       01 WS-ANNEE         PIC X(4).
       01 WS-FIN-COMPTE    PIC X VALUE 'N'.
       01 WS-FIN-TRANS     PIC X VALUE 'N'.
       01 WS-COMPTEUR      PIC 9(6) VALUE 0.
       01 WS-TOTAL-INTERETS PIC 9(15)V99 VALUE 0.
       01 WS-NB-COMPTES    PIC 9(6) VALUE 0.
       01 WS-TAUX-BASE     PIC 9(4)V99 VALUE 3.50.
       01 WS-INTERETS      PIC 9(10)V99 VALUE 0.
       01 WS-NOUVEAU-SOLDE PIC 9(10)V99 VALUE 0.
       01 WS-TOTAL-DEPOTS  PIC 9(15)V99 VALUE 0.
       01 WS-TOTAL-RETRAITS PIC 9(15)V99 VALUE 0.
       01 WS-INTERETS-EDIT PIC Z(9)9.99.
       01 WS-TOTAL-EDIT    PIC Z(9)9.99.
       
       PROCEDURE DIVISION.
           DISPLAY "========================================="
           DISPLAY "=== BATCH MENSUEL - CALCUL DES INTERETS ==="
           DISPLAY "========================================="
           DISPLAY " "
           
           ACCEPT WS-ANNEE FROM DATE YYYY
           ACCEPT WS-MOIS FROM DATE MM
           
           OPEN OUTPUT FICHIER-RAPPORT
           
      *> En-tete rapport
           MOVE SPACES TO ENR-RAPPORT
           STRING "============================================"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           MOVE SPACES TO ENR-RAPPORT
           STRING "RAPPORT BANCAIRE MENSUEL - " WS-ANNEE "/" WS-MOIS
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           MOVE SPACES TO ENR-RAPPORT
           STRING "============================================"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           WRITE ENR-RAPPORT
           
      *> Analyser transactions du mois
           OPEN INPUT FICHIER-TRANSACTION
           MOVE 'N' TO WS-FIN-TRANS
           MOVE 0 TO WS-TOTAL-DEPOTS
           MOVE 0 TO WS-TOTAL-RETRAITS
           
           PERFORM UNTIL WS-FIN-TRANS = 'Y'
               READ FICHIER-TRANSACTION
                   AT END MOVE 'Y' TO WS-FIN-TRANS
                   NOT AT END
                       IF DATE-TRANS(1:7) = WS-ANNEE(3:4) 
                          AND DATE-TRANS(6:2) = WS-MOIS
                           IF TYPE-TRANS = "DEPOT"
                               ADD MONTANT-TRANS TO WS-TOTAL-DEPOTS
                           ELSE
                               IF TYPE-TRANS = "RETRAIT"
                                   ADD MONTANT-TRANS TO WS-TOTAL-RETRAITS
                               END-IF
                           END-IF
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-TRANSACTION
           
           MOVE WS-TOTAL-DEPOTS TO WS-TOTAL-EDIT
           MOVE SPACES TO ENR-RAPPORT
           STRING "Total depots du mois: " WS-TOTAL-EDIT " €"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           MOVE WS-TOTAL-RETRAITS TO WS-TOTAL-EDIT
           MOVE SPACES TO ENR-RAPPORT
           STRING "Total retraits du mois: " WS-TOTAL-EDIT " €"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           WRITE ENR-RAPPORT
           
      *> Calcul des interets
           MOVE SPACES TO ENR-RAPPORT
           STRING "--- CALCUL DES INTERETS (Taux: " 
               WS-TAUX-BASE "%) ---"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           OPEN INPUT FICHIER-COMPTE
           OPEN OUTPUT FICHIER-TEMP
           MOVE 'N' TO WS-FIN-COMPTE
           MOVE 0 TO WS-TOTAL-INTERETS
           MOVE 0 TO WS-NB-COMPTES
           
           PERFORM UNTIL WS-FIN-COMPTE = 'Y'
               READ FICHIER-COMPTE
                   AT END MOVE 'Y' TO WS-FIN-COMPTE
                   NOT AT END
                       IF TYPE-COMPTE = "EPARGNE"
                           COMPUTE WS-INTERETS = 
                               SOLDE-COMPTE * WS-TAUX-BASE / 1200
                           ADD WS-INTERETS TO WS-TOTAL-INTERETS
                           ADD WS-INTERETS TO SOLDE-COMPTE
                           ADD 1 TO WS-NB-COMPTES
                           
                           MOVE WS-INTERETS TO WS-INTERETS-EDIT
                           MOVE SPACES TO ENR-RAPPORT
                           STRING "Compte " NUM-COMPTE
                               " - Interets: " WS-INTERETS-EDIT " €"
                               INTO ENR-RAPPORT
                           WRITE ENR-RAPPORT
                       END-IF
                       MOVE ENR-COMPTE TO ENR-TEMP
                       WRITE ENR-TEMP
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-COMPTE, FICHIER-TEMP
           
           CALL 'SYSTEM' USING 
               'mv data/temp/COMPTES.TMP data/input/COMPTES.dat'
           
           MOVE WS-TOTAL-INTERETS TO WS-TOTAL-EDIT
           MOVE SPACES TO ENR-RAPPORT
           STRING "Total interets verses: " WS-TOTAL-EDIT " €"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           WRITE ENR-RAPPORT
           
      *> Pied de page
           MOVE SPACES TO ENR-RAPPORT
           STRING "============================================"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           MOVE SPACES TO ENR-RAPPORT
           STRING "FIN DU RAPPORT MENSUEL"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           MOVE SPACES TO ENR-RAPPORT
           STRING "============================================"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           CLOSE FICHIER-RAPPORT
           
           DISPLAY " "
           DISPLAY "========================================="
           DISPLAY "--- BATCH MENSUEL TERMINE ---"
           DISPLAY "========================================="
           DISPLAY "Rapport: data/output/reports/RAPPORT_MENSUEL.rpt"
           DISPLAY "Interets verses: " WS-TOTAL-INTERETS " €"
           DISPLAY "Comptes majories: " WS-NB-COMPTES
           DISPLAY "========================================="
           
           STOP RUN.
