       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUT-CREDIT.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CREDIT ASSIGN TO 'data/input/CREDITS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-COMPTE ASSIGN TO 'data/input/COMPTES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-CREDIT.
       01 ENR-CREDIT.
          05 ID-CREDIT       PIC X(6).
          05 FILLER          PIC X(1).
          05 NUM-COMPTE      PIC X(6).
          05 FILLER          PIC X(1).
          05 MONTANT         PIC 9(9)V99.
          05 FILLER          PIC X(1).
          05 TAUX            PIC 9(4)V99.
          05 FILLER          PIC X(1).
          05 DUREE           PIC 9(5).
          05 FILLER          PIC X(1).
          05 MENSUALITE      PIC 9(9)V99.
          05 FILLER          PIC X(1).
          05 DATE-DEBUT      PIC X(10).
          05 FILLER          PIC X(1).
          05 STATUT          PIC X(3).
       
       FD FICHIER-COMPTE.
       01 ENR-COMPTE.
          05 NUM-COMPTE-C     PIC X(6).
          05 FILLER           PIC X(1).
          05 ID-CLIENT-C      PIC X(6).
          05 FILLER           PIC X(1).
          05 TYPE-COMPTE      PIC X(4).
          05 FILLER           PIC X(1).
          05 SOLDE-COMPTE     PIC 9(9)V99.
          05 FILLER           PIC X(1).
          05 DATE-OUV-COMP    PIC X(10).
       
       WORKING-STORAGE SECTION.
       01 WS-ID-CREDIT       PIC X(6).
       01 WS-NUM-COMPTE      PIC X(6).
       01 WS-MONTANT         PIC 9(9)V99.
       01 WS-TAUX            PIC 9(4)V99.
       01 WS-DUREE           PIC 9(5).
       01 WS-MENSUALITE      PIC 9(9)V99.
       01 WS-DATE            PIC X(10).
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-COMPTE-TROUVE   PIC X VALUE 'N'.
       01 WS-COUNT           PIC 9(6) VALUE 0.
       01 WS-MONTANT-AFF     PIC Z(9)9.99.
       01 WS-MENSUALITE-AFF  PIC Z(9)9.99.
       01 WS-TAUX-AFF        PIC Z(9)9.99.
       
       PROCEDURE DIVISION.
           DISPLAY "=== DEMANDE DE CREDIT ==="
           DISPLAY " "
           
           DISPLAY "NUMERO DE COMPTE: "
           ACCEPT WS-NUM-COMPTE
           DISPLAY "MONTANT EMPRUNTE: "
           ACCEPT WS-MONTANT
           DISPLAY "TAUX ANNUEL (%): "
           ACCEPT WS-TAUX
           DISPLAY "DUREE (Mois): "
           ACCEPT WS-DUREE
           
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
      *> Verifier que le compte existe
           OPEN INPUT FICHIER-COMPTE
           MOVE 'N' TO WS-COMPTE-TROUVE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-COMPTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF NUM-COMPTE-C = WS-NUM-COMPTE
                           MOVE 'Y' TO WS-COMPTE-TROUVE
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-COMPTE
           
           IF WS-COMPTE-TROUVE = 'N'
               DISPLAY "ERREUR: Compte inexistant"
               STOP RUN
           END-IF
           
      *> Calculer la mensualite
      *> Formule: M = P * (t/12) / (1 - (1 + t/12)^-n)
           COMPUTE WS-MENSUALITE = 
               (WS-MONTANT * (WS-TAUX / 1200)) / 
               (1 - (1 + (WS-TAUX / 1200)) ** (-WS-DUREE))
           
      *> Generer ID credit
           OPEN INPUT FICHIER-CREDIT
           MOVE 0 TO WS-COUNT
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CREDIT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COUNT
               END-READ
           END-PERFORM
           CLOSE FICHIER-CREDIT
           
           ADD 1 TO WS-COUNT
           STRING 'CR' DELIMITED BY SIZE
                  WS-COUNT DELIMITED BY SIZE
                  INTO WS-ID-CREDIT
           
           IF WS-COUNT < 10
               STRING 'CR000' WS-COUNT INTO WS-ID-CREDIT
           ELSE
               IF WS-COUNT < 100
                   STRING 'CR00' WS-COUNT INTO WS-ID-CREDIT
               ELSE
                   IF WS-COUNT < 1000
                       STRING 'CR0' WS-COUNT INTO WS-ID-CREDIT
                   ELSE
                       STRING 'CR' WS-COUNT INTO WS-ID-CREDIT
                   END-END
               END-IF
           END-IF
           
      *> Ajouter le credit
           OPEN EXTEND FICHIER-CREDIT
           
           MOVE WS-ID-CREDIT TO ID-CREDIT
           MOVE WS-NUM-COMPTE TO NUM-COMPTE
           MOVE WS-MONTANT TO MONTANT
           MOVE WS-TAUX TO TAUX
           MOVE WS-DUREE TO DUREE
           MOVE WS-MENSUALITE TO MENSUALITE
           MOVE WS-DATE TO DATE-DEBUT
           MOVE 'ACT' TO STATUT
           
           WRITE ENR-CREDIT
           CLOSE FICHIER-CREDIT
           
           MOVE WS-MONTANT TO WS-MONTANT-AFF
           MOVE WS-MENSUALITE TO WS-MENSUALITE-AFF
           MOVE WS-TAUX TO WS-TAUX-AFF
           
           DISPLAY " "
           DISPLAY "--- CREDIT ENREGISTRE ---"
           DISPLAY "ID CREDIT    : " WS-ID-CREDIT
           DISPLAY "COMPTE       : " WS-NUM-COMPTE
           DISPLAY "MONTANT      : " WS-MONTANT-AFF " €"
           DISPLAY "TAUX         : " WS-TAUX-AFF " %"
           DISPLAY "DUREE        : " WS-DUREE " mois"
           DISPLAY "MENSUALITE   : " WS-MENSUALITE-AFF " €/mois"
           DISPLAY "DATE DEBUT   : " WS-DATE
           DISPLAY "STATUT       : ACTIF"
           
           STOP RUN.