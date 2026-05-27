       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUT-CREDIT.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CREDIT ASSIGN TO 'data/input/CREDITS.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-COMPTE ASSIGN TO 'data/input/COMPTES.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-CLIENT ASSIGN TO 'data/input/CLIENTS.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-CREDIT.
       01 ENR-CREDIT.
          05 ID-CREDIT      PIC X(6).
          05 FILLER         PIC X(1).
          05 NUM-COMPTE-CR  PIC X(6).
          05 FILLER         PIC X(1).
          05 MONTANT-CREDIT PIC 9(10)V99.
          05 FILLER         PIC X(1).
          05 TAUX-CREDIT    PIC 9(4)V99.
          05 FILLER         PIC X(1).
          05 DUREE-CREDIT   PIC 9(5).
          05 FILLER         PIC X(1).
          05 MENSUALITE     PIC 9(10)V99.
          05 FILLER         PIC X(1).
          05 DATE-DEBUT     PIC X(10).
          05 FILLER         PIC X(1).
          05 STATUT-CR      PIC X(5).
          05 FILLER         PIC X(1).
          05 CAPITAL-RESTANT PIC 9(10)V99.
       
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
       
       FD FICHIER-CLIENT.
       01 ENR-CLIENT.
          05 ID-CLIENT      PIC X(6).
          05 FILLER         PIC X(1).
          05 NOM-CLIENT     PIC X(20).
          05 FILLER         PIC X(1).
          05 PRENOM-CLIENT  PIC X(15).
          05 FILLER         PIC X(1).
          05 ADRESSE-CLIENT PIC X(35).
          05 FILLER         PIC X(1).
          05 CP-CLIENT      PIC X(5).
          05 FILLER         PIC X(1).
          05 VILLE-CLIENT   PIC X(20).
          05 FILLER         PIC X(1).
          05 TEL-CLIENT     PIC X(10).
          05 FILLER         PIC X(1).
          05 EMAIL-CLIENT   PIC X(30).
          05 FILLER         PIC X(1).
          05 REVENU-CLIENT  PIC 9(8)V99.
          05 FILLER         PIC X(1).
          05 DATE-OUVERTURE PIC X(10).
          05 FILLER         PIC X(1).
          05 STATUT-CLIENT  PIC X(7).
          05 FILLER         PIC X(1).
          05 CATEGORIE      PIC X(10).
       
       WORKING-STORAGE SECTION.
       01 WS-ID            PIC X(6).
       01 WS-NUM-COMPTE    PIC X(6).
       01 WS-MONTANT       PIC 9(10)V99.
       01 WS-TAUX          PIC 9(4)V99.
       01 WS-DUREE         PIC 9(5).
       01 WS-MENSUALITE    PIC 9(10)V99.
       01 WS-DATE          PIC X(10).
       01 WS-CAPITAL-RESTANT PIC 9(10)V99.
       01 WS-REVENU        PIC 9(8)V99.
       01 WS-SOLDE         PIC 9(10)V99.
       01 WS-FIN           PIC X VALUE 'N'.
       01 WS-COMPTE-EXISTE PIC X VALUE 'N'.
       01 WS-COUNT         PIC 9(6) VALUE 0.
       01 WS-MONTANT-EDIT  PIC Z(9)9.99.
       01 WS-MENSUALITE-EDIT PIC Z(9)9.99.
       01 WS-TAUX-EDIT     PIC Z(4)9.99.
       01 WS-CAPACITE      PIC 9(10)V99.
       
       PROCEDURE DIVISION.
           DISPLAY "========================================="
           DISPLAY "=== DEMANDE DE CREDIT ==="
           DISPLAY "========================================="
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
           
      *> Verification compte et recuperation revenu
           OPEN INPUT FICHIER-COMPTE
           MOVE 'N' TO WS-COMPTE-EXISTE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-COMPTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF NUM-COMPTE = WS-NUM-COMPTE
                           MOVE 'Y' TO WS-COMPTE-EXISTE
                           MOVE ID-CLI-COMPTE TO WS-ID-CLIENT
                           MOVE SOLDE-COMPTE TO WS-SOLDE
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-COMPTE
           
           IF WS-COMPTE-EXISTE = 'N'
               DISPLAY "ERREUR: Compte inexistant"
               STOP RUN
           END-IF
           
      *> Recuperer revenu client
           OPEN INPUT FICHIER-CLIENT
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CLIENT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-CLIENT = WS-ID-CLIENT
                           MOVE REVENU-CLIENT TO WS-REVENU
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-CLIENT
           
      *> Verifier capacite d'emprunt (max 35% des revenus annuels)
           COMPUTE WS-CAPACITE = WS-REVENU * 0.35
           
           IF WS-MONTANT > WS-CAPACITE
               DISPLAY "ERREUR: Montant depasse capacite d'emprunt"
               DISPLAY "Capacite max: " WS-CAPACITE " €"
               STOP RUN
           END-IF
           
      *> Calcul de la mensualite
      *> M = P * (t/12) / (1 - (1 + t/12)^-n)
           COMPUTE WS-MENSUALITE = 
               (WS-MONTANT * (WS-TAUX / 1200)) / 
               (1 - (1 + (WS-TAUX / 1200)) ** (-WS-DUREE))
           
           MOVE WS-MONTANT TO WS-CAPITAL-RESTANT
           
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
           IF WS-COUNT < 10
               STRING 'CR00' WS-COUNT INTO WS-ID
           ELSE
               IF WS-COUNT < 100
                   STRING 'CR0' WS-COUNT INTO WS-ID
               ELSE
                   STRING 'CR' WS-COUNT INTO WS-ID
               END-IF
           END-IF
           
      *> Ajout credit
           OPEN EXTEND FICHIER-CREDIT
           
           MOVE WS-ID TO ID-CREDIT
           MOVE WS-NUM-COMPTE TO NUM-COMPTE-CR
           MOVE WS-MONTANT TO MONTANT-CREDIT
           MOVE WS-TAUX TO TAUX-CREDIT
           MOVE WS-DUREE TO DUREE-CREDIT
           MOVE WS-MENSUALITE TO MENSUALITE
           MOVE WS-DATE TO DATE-DEBUT
           MOVE "ACTIF" TO STATUT-CR
           MOVE WS-CAPITAL-RESTANT TO CAPITAL-RESTANT
           
           WRITE ENR-CREDIT
           CLOSE FICHIER-CREDIT
           
           MOVE WS-MONTANT TO WS-MONTANT-EDIT
           MOVE WS-MENSUALITE TO WS-MENSUALITE-EDIT
           MOVE WS-TAUX TO WS-TAUX-EDIT
           
           DISPLAY " "
           DISPLAY "========================================="
           DISPLAY "=== CREDIT ACCORDE AVEC SUCCES ==="
           DISPLAY "========================================="
           DISPLAY "ID CREDIT    : " WS-ID
           DISPLAY "COMPTE       : " WS-NUM-COMPTE
           DISPLAY "MONTANT      : " WS-MONTANT-EDIT " €"
           DISPLAY "TAUX         : " WS-TAUX-EDIT " %"
           DISPLAY "DUREE        : " WS-DUREE " mois"
           DISPLAY "MENSUALITE   : " WS-MENSUALITE-EDIT " €/mois"
           DISPLAY "DATE DEBUT   : " WS-DATE
           DISPLAY "STATUT       : ACTIF"
           DISPLAY "========================================="
           
           STOP RUN.
