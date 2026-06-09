       IDENTIFICATION DIVISION.
       PROGRAM-ID. BATCH-QUOTIDIEN.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-COMPTE ASSIGN TO 'data/input/COMPTES.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-TRANSACTION ASSIGN TO 'data/input/TRANSACTIONS.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-RAPPORT ASSIGN TO 
               'data/output/reports/RAPPORT_JOURNALIER.rpt'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-ALERTES ASSIGN TO 
               'data/output/reports/ALERTES.rpt'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-COMPTE.
       01 ENR-COMPTE.
          05 NUM-COMPTE      PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-CLI-COMPTE   PIC X(6).
          05 FILLER          PIC X(1).
          05 TYPE-COMPTE     PIC X(10).
          05 FILLER          PIC X(1).
          05 SOLDE-COMPTE    PIC 9(10)V99.
          05 FILLER          PIC X(1).
          05 DECOUVERT       PIC 9(10)V99.
          05 FILLER          PIC X(1).
          05 DATE-OUV        PIC X(10).
          05 FILLER          PIC X(1).
          05 STATUT-COMPTE   PIC X(6).
       
       FD FICHIER-TRANSACTION.
       01 ENR-TRANS.
          05 ID-TRANS        PIC X(15).
          05 FILLER          PIC X(1).
          05 NUM-COMPTE-T    PIC X(6).
          05 FILLER          PIC X(1).
          05 DATE-TRANS      PIC X(10).
          05 FILLER          PIC X(1).
          05 MONTANT-TRANS   PIC 9(10)V99.
          05 FILLER          PIC X(1).
          05 TYPE-TRANS      PIC X(15).
          05 FILLER          PIC X(1).
          05 MODE-TRANS      PIC X(10).
          05 FILLER          PIC X(1).
          05 STATUT-TRANS    PIC X(7).
       
       FD FICHIER-RAPPORT.
       01 ENR-RAPPORT       PIC X(80).
       
       FD FICHIER-ALERTES.
       01 ENR-ALERTE        PIC X(80).
       
       WORKING-STORAGE SECTION.
       01 WS-DATE-COURANTE  PIC X(10).
       01 WS-FIN-COMPTE     PIC X VALUE 'N'.
       01 WS-FIN-TRANS      PIC X VALUE 'N'.
       01 WS-TOTAL-DEPOTS   PIC 9(15)V99 VALUE 0.
       01 WS-TOTAL-RETRAITS PIC 9(15)V99 VALUE 0.
       01 WS-TOTAL-VIREMENTS PIC 9(15)V99 VALUE 0.
       01 WS-NB-TRANSACTIONS PIC 9(8) VALUE 0.
       01 WS-NB-ALERTES     PIC 9(8) VALUE 0.
       01 WS-COMPTEUR       PIC 9(6) VALUE 0.
       01 WS-SOLDE-MOYEN    PIC 9(10)V99.
       01 WS-TEMP-MONTANT   PIC 9(10)V99.
       01 WS-SEUIL-ALERTE   PIC 9(10)V99 VALUE 1000.00.
       01 WS-MONTANT-EDIT   PIC Z(9)9.99.
       01 WS-TOTAL-EDIT     PIC Z(9)9.99.
       
       PROCEDURE DIVISION.
           DISPLAY "=== BATCH QUOTIDIEN ==="
           DISPLAY "Date de traitement: $(date +%Y-%m-%d)"
           DISPLAY " "
           
           ACCEPT WS-DATE-COURANTE FROM DATE YYYYMMDD
           
           OPEN OUTPUT FICHIER-RAPPORT
           OPEN OUTPUT FICHIER-ALERTES
           
      *> En-tete du rapport
           MOVE SPACES TO ENR-RAPPORT
           STRING "============================================"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           MOVE SPACES TO ENR-RAPPORT
           STRING "RAPPORT BANCAIRE JOURNALIER DU " WS-DATE-COURANTE
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           MOVE SPACES TO ENR-RAPPORT
           STRING "============================================"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           WRITE ENR-RAPPORT
           
      *> Analyser les transactions du jour
           OPEN INPUT FICHIER-TRANSACTION
           MOVE 'N' TO WS-FIN-TRANS
           MOVE 0 TO WS-NB-TRANSACTIONS
           MOVE 0 TO WS-TOTAL-DEPOTS
           MOVE 0 TO WS-TOTAL-RETRAITS
           MOVE 0 TO WS-TOTAL-VIREMENTS
           
           PERFORM UNTIL WS-FIN-TRANS = 'Y'
               READ FICHIER-TRANSACTION
                   AT END MOVE 'Y' TO WS-FIN-TRANS
                   NOT AT END
                       IF DATE-TRANS = WS-DATE-COURANTE
                           ADD 1 TO WS-NB-TRANSACTIONS
                           MOVE MONTANT-TRANS TO WS-TEMP-MONTANT
                           MOVE WS-TEMP-MONTANT TO WS-MONTANT-EDIT
                           
                           IF TYPE-TRANS = 'DEPOT'
                               ADD MONTANT-TRANS TO WS-TOTAL-DEPOTS
                           ELSE
                               IF TYPE-TRANS = 'RETRAIT'
                                   ADD MONTANT-TRANS TO 
                                       WS-TOTAL-RETRAITS
                               ELSE
                                   IF TYPE-TRANS = 'VIREMENT'
                                       ADD MONTANT-TRANS TO 
                                           WS-TOTAL-VIREMENTS
                                   END-IF
                               END-IF
                           END-IF
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-TRANSACTION
           
      *> Afficher resume transactions
           MOVE SPACES TO ENR-RAPPORT
           STRING "--- RESUME DES TRANSACTIONS ---"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           MOVE WS-TOTAL-DEPOTS TO WS-TOTAL-EDIT
           MOVE SPACES TO ENR-RAPPORT
           STRING "Total des depots   : " WS-TOTAL-EDIT " €"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           MOVE WS-TOTAL-RETRAITS TO WS-TOTAL-EDIT
           MOVE SPACES TO ENR-RAPPORT
           STRING "Total des retraits : " WS-TOTAL-EDIT " €"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           MOVE WS-TOTAL-VIREMENTS TO WS-TOTAL-EDIT
           MOVE SPACES TO ENR-RAPPORT
           STRING "Total des virements: " WS-TOTAL-EDIT " €"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           MOVE SPACES TO ENR-RAPPORT
           STRING "Nombre transactions: " WS-NB-TRANSACTIONS
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           WRITE ENR-RAPPORT
           
      *> Analyser les comptes
           MOVE SPACES TO ENR-RAPPORT
           STRING "--- ANALYSE DES COMPTES ---"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           OPEN INPUT FICHIER-COMPTE
           MOVE 'N' TO WS-FIN-COMPTE
           MOVE 0 TO WS-COMPTEUR
           MOVE 0 TO WS-TOTAL-VIREMENTS
           
           PERFORM UNTIL WS-FIN-COMPTE = 'Y'
               READ FICHIER-COMPTE
                   AT END MOVE 'Y' TO WS-FIN-COMPTE
                   NOT AT END
                       ADD 1 TO WS-COMPTEUR
                       ADD SOLDE-COMPTE TO WS-TOTAL-VIREMENTS
                       
      *> Verifier alertes
                       IF SOLDE-COMPTE < WS-SEUIL-ALERTE
                           ADD 1 TO WS-NB-ALERTES
                           MOVE SPACES TO ENR-ALERTE
                           STRING "ALERTE: Compte " NUM-COMPTE
                               " solde " SOLDE-COMPTE " €"
                               INTO ENR-ALERTE
                           WRITE ENR-ALERTE
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-COMPTE
           
           COMPUTE WS-SOLDE-MOYEN = 
               WS-TOTAL-VIREMENTS / WS-COMPTEUR
           
           MOVE SPACES TO ENR-RAPPORT
           STRING "Nombre total de comptes: " WS-COMPTEUR
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           MOVE WS-SOLDE-MOYEN TO WS-TOTAL-EDIT
           MOVE SPACES TO ENR-RAPPORT
           STRING "Solde moyen des comptes: " WS-TOTAL-EDIT " €"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           MOVE SPACES TO ENR-RAPPORT
           STRING "Nombre d'alertes generees: " WS-NB-ALERTES
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           WRITE ENR-RAPPORT
           
      *> Pied de page
           MOVE SPACES TO ENR-RAPPORT
           STRING "============================================"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           MOVE SPACES TO ENR-RAPPORT
           STRING "FIN DU RAPPORT - BATCH QUOTIDIEN"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           MOVE SPACES TO ENR-RAPPORT
           STRING "============================================"
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           CLOSE FICHIER-RAPPORT
           CLOSE FICHIER-ALERTES
           
           DISPLAY " "
           DISPLAY "--- BATCH QUOTIDIEN TERMINE ---"
           DISPLAY "Rapport genere: data/output/reports/RAPPORT_JOURNALIER.rpt"
           DISPLAY "Alertes generees: data/output/reports/ALERTES.rpt"
           DISPLAY "Total transactions: " WS-NB-TRANSACTIONS
           DISPLAY "Alertes: " WS-NB-ALERTES
           
           STOP RUN.
