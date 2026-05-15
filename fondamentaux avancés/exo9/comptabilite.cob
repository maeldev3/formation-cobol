IDENTIFICATION DIVISION.
       PROGRAM-ID. COMPTABILITE.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-COMPTES
               ASSIGN TO "comptes.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-NUM-COMPTE
               FILE STATUS IS WS-FS.
           
           SELECT FICHIER-JOURNAL
               ASSIGN TO "journal.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-ECR-NUM
               FILE STATUS IS WS-FS-JOUR.
           
           SELECT FICHIER-BALANCE
               ASSIGN TO "balance.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-COMPTES.
       01 WS-COMPTE.
           05 WS-NUM-COMPTE       PIC 9(6).
           05 WS-LIBELLE          PIC X(40).
           05 WS-TYPE-COMPTE      PIC X(2).
              88 ACTIF            VALUE 'AC'.
              88 PASSIF           VALUE 'PA'.
              88 CHARGE           VALUE 'CH'.
              88 PRODUIT          VALUE 'PR'.
           05 WS-SOLDE-DEBIT      PIC 9(12)V99.
           05 WS-SOLDE-CREDIT     PIC 9(12)V99.
           05 WS-CLASSE           PIC 9(2).

       FD FICHIER-JOURNAL.
       01 WS-ECRITURE.
           05 WS-ECR-NUM          PIC 9(8).
           05 WS-ECR-DATE         PIC 9(8).
           05 WS-ECR-COMPTE-DEBIT PIC 9(6).
           05 WS-ECR-COMPTE-CREDIT PIC 9(6).
           05 WS-ECR-MONTANT      PIC 9(12)V99.
           05 WS-ECR-LIBELLE      PIC X(60).
           05 WS-ECR-PIECE        PIC X(15).
           05 WS-ECR-LETTRAGE     PIC X(2).

       FD FICHIER-BALANCE.
       01 REG-BALANCE             PIC X(120).

       WORKING-STORAGE SECTION.
       01 WS-FS                   PIC XX.
       01 WS-FS-JOUR              PIC XX.
       01 WS-CHOIX                PIC 99.
       01 WS-QUITTER              PIC X(1) VALUE 'N'.
       01 WS-NUM-COMPTE-RECH      PIC 9(6).
       01 WS-NUM-ECR-RECH         PIC 9(8).
       01 WS-DATE-COURANTE.
           05 WS-DATE-ANNEE       PIC 9(4).
           05 WS-DATE-MOIS        PIC 9(2).
           05 WS-DATE-JOUR        PIC 9(2).
       
       *> Variables de saisie
       01 WS-DATE-SAIE            PIC 9(8).
       01 WS-PIECE                PIC X(15).
       01 WS-LIB-OP               PIC X(60).
       01 WS-COMPTE-DEB           PIC 9(6).
       01 WS-COMPTE-CRED          PIC 9(6).
       01 WS-MONTANT              PIC 9(12)V99.
       01 WS-NUM-ECRITURE         PIC 9(8) VALUE 0.
       01 WS-LETTRE               PIC X(2).
       01 WS-NEW-LETTRE           PIC X(2).

       *> Variables de calcul
       01 WS-SOLDE                PIC 9(12)V99.
       01 WS-TOTAL-DEBIT          PIC 9(12)V99.
       01 WS-TOTAL-CREDIT         PIC 9(12)V99.
       01 WS-DATE-DEB             PIC 9(8).
       01 WS-DATE-FIN             PIC 9(8).
       01 WS-DATE-ARRET           PIC 9(8).
       01 WS-COMPTE-CLIENT        PIC 9(6).

       *> Postes du Bilan et Résultat
       01 WS-CAPITAL              PIC S9(12)V99.
       01 WS-DETTES-FRS           PIC S9(12)V99.
       01 WS-CREANCES             PIC S9(12)V99.
       01 WS-BANQUE               PIC S9(12)V99.
       01 WS-CAISSE               PIC S9(12)V99.
       01 WS-TOTAL-ACTIF          PIC S9(12)V99.
       01 WS-TOTAL-PASSIF         PIC S9(12)V99.
       01 WS-VENTES               PIC S9(12)V99.
       01 WS-ACHATS               PIC S9(12)V99.
       01 WS-CHARGES-PERSO        PIC S9(12)V99.
       01 WS-TOTAL-PRODUITS       PIC S9(12)V99.
       01 WS-TOTAL-CHARGES        PIC S9(12)V99.
       01 WS-RESULTAT             PIC S9(12)V99.
       01 WS-CALC-TEMP            PIC S9(12)V99.

       PROCEDURE DIVISION.
           PERFORM 1000-INITIALISATION
           PERFORM UNTIL WS-QUITTER = 'O'
               PERFORM 2000-MENU-PRINCIPAL
               PERFORM 3000-TRAITER-MENU
           END-PERFORM
           PERFORM 9999-FERMETURE
           STOP RUN.

       1000-INITIALISATION.
           DISPLAY "======================================"
           DISPLAY "      SYSTEME COMPTABLE INTEGRE"
           DISPLAY "======================================"
           MOVE FUNCTION CURRENT-DATE TO WS-DATE-COURANTE
           
           OPEN I-O FICHIER-COMPTES
           IF WS-FS NOT = '00'
               OPEN OUTPUT FICHIER-COMPTES
               CLOSE FICHIER-COMPTES
               OPEN I-O FICHIER-COMPTES
               PERFORM 1100-CHARGER-PLAN-COMPTABLE
           END-IF
           
           OPEN I-O FICHIER-JOURNAL
           IF WS-FS-JOUR NOT = '00'
               OPEN OUTPUT FICHIER-JOURNAL
               CLOSE FICHIER-JOURNAL
               OPEN I-O FICHIER-JOURNAL
           END-IF.

       1100-CHARGER-PLAN-COMPTABLE.
           MOVE 601000 TO WS-NUM-COMPTE
           MOVE "ACHATS DE MARCHANDISES" TO WS-LIBELLE
           MOVE "CH" TO WS-TYPE-COMPTE
           MOVE 0 TO WS-SOLDE-DEBIT WS-SOLDE-CREDIT
           MOVE 6 TO WS-CLASSE
           WRITE WS-COMPTE
           
           MOVE 701000 TO WS-NUM-COMPTE
           MOVE "VENTES DE MARCHANDISES" TO WS-LIBELLE
           MOVE "PR" TO WS-TYPE-COMPTE
           MOVE 0 TO WS-SOLDE-DEBIT WS-SOLDE-CREDIT
           MOVE 7 TO WS-CLASSE
           WRITE WS-COMPTE
           
           MOVE 201000 TO WS-NUM-COMPTE
           MOVE "BANQUE" TO WS-LIBELLE
           MOVE "AC" TO WS-TYPE-COMPTE
           MOVE 10000 TO WS-SOLDE-DEBIT
           MOVE 0 TO WS-SOLDE-CREDIT
           MOVE 2 TO WS-CLASSE
           WRITE WS-COMPTE
           DISPLAY "PLAN COMPTABLE INITIALISE.".

       2000-MENU-PRINCIPAL.
           DISPLAY " "
           DISPLAY "1. SAISIR ECRITURE"
           DISPLAY "2. GRAND LIVRE"
           DISPLAY "3. BALANCE GENERALE"
           DISPLAY "6. BILAN"
           DISPLAY "7. RESULTAT"
           DISPLAY "8. LETTRAGE"
           DISPLAY "9. TABLEAU DE BORD"
           DISPLAY "10. QUITTER"
           ACCEPT WS-CHOIX.

       3000-TRAITER-MENU.
           EVALUATE WS-CHOIX
               WHEN 1  PERFORM 4000-SAISIR-ECRITURE
               WHEN 2  PERFORM 5000-GRAND-LIVRE
               WHEN 3  PERFORM 6000-BALANCE-GENERALE
               WHEN 6  PERFORM 7000-BILAN
               WHEN 7  PERFORM 8000-RESULTAT
               WHEN 8  PERFORM 9000-LETTRAGE
               WHEN 9  PERFORM 9100-TABLEAU-BORD
               WHEN 10 MOVE 'O' TO WS-QUITTER
           END-EVALUATE.

       4000-SAISIR-ECRITURE.
           DISPLAY "DATE (JJMMAAAA): " ACCEPT WS-DATE-SAIE
           DISPLAY "PIECE: " ACCEPT WS-PIECE
           DISPLAY "LIBELLE: " ACCEPT WS-LIB-OP
           DISPLAY "COMPTE DEBIT: " ACCEPT WS-COMPTE-DEB
           DISPLAY "MONTANT: " ACCEPT WS-MONTANT
           DISPLAY "COMPTE CREDIT: " ACCEPT WS-COMPTE-CRED
           
           ADD 1 TO WS-NUM-ECRITURE
           MOVE WS-NUM-ECRITURE TO WS-ECR-NUM
           MOVE WS-DATE-SAIE TO WS-ECR-DATE
           MOVE WS-COMPTE-DEB TO WS-ECR-COMPTE-DEBIT
           MOVE WS-COMPTE-CRED TO WS-ECR-COMPTE-CREDIT
           MOVE WS-MONTANT TO WS-ECR-MONTANT
           MOVE WS-LIB-OP TO WS-ECR-LIBELLE
           MOVE WS-PIECE TO WS-ECR-PIECE
           MOVE SPACES TO WS-ECR-LETTRAGE
           WRITE WS-ECRITURE
           
           PERFORM 4200-MAJ-GRAND-LIVRE.

       4200-MAJ-GRAND-LIVRE.
           MOVE WS-COMPTE-DEB TO WS-NUM-COMPTE
           READ FICHIER-COMPTES
               NOT INVALID KEY
                   ADD WS-MONTANT TO WS-SOLDE-DEBIT
                   REWRITE WS-COMPTE
           END-READ
           MOVE WS-COMPTE-CRED TO WS-NUM-COMPTE
           READ FICHIER-COMPTES
               NOT INVALID KEY
                   ADD WS-MONTANT TO WS-SOLDE-CREDIT
                   REWRITE WS-COMPTE
           END-READ.

       5000-GRAND-LIVRE.
           DISPLAY "NUMERO COMPTE: " ACCEPT WS-NUM-COMPTE-RECH
           MOVE WS-NUM-COMPTE-RECH TO WS-NUM-COMPTE
           READ FICHIER-COMPTES
               INVALID KEY DISPLAY "NON TROUVE"
               NOT INVALID KEY
                   DISPLAY "LIBELLE: " WS-LIBELLE
                   DISPLAY "DEBIT: " WS-SOLDE-DEBIT
                   DISPLAY "CREDIT: " WS-SOLDE-CREDIT
           END-READ.

       6000-BALANCE-GENERALE.
           MOVE 0 TO WS-NUM-COMPTE
           START FICHIER-COMPTES KEY IS NOT < WS-NUM-COMPTE
           PERFORM UNTIL WS-FS = '10'
               READ FICHIER-COMPTES NEXT
                   AT END MOVE '10' TO WS-FS
                   NOT AT END 
                       DISPLAY WS-NUM-COMPTE " | " WS-LIBELLE 
                               " | " WS-SOLDE-DEBIT " | " WS-SOLDE-CREDIT
               END-READ
           END-PERFORM
           MOVE '00' TO WS-FS.

       7000-BILAN.
           PERFORM 7010-CALCULER-BILAN
           DISPLAY "TOTAL ACTIF: " WS-TOTAL-ACTIF
           DISPLAY "TOTAL PASSIF: " WS-TOTAL-PASSIF.

       7010-CALCULER-BILAN.
           MOVE 0 TO WS-TOTAL-ACTIF WS-TOTAL-PASSIF.
           *> Logique simplifiée pour l'exemple
           MOVE 201000 TO WS-NUM-COMPTE
           READ FICHIER-COMPTES
               NOT INVALID KEY COMPUTE WS-TOTAL-ACTIF = WS-SOLDE-DEBIT - WS-SOLDE-CREDIT
           END-READ.

       8000-RESULTAT.
           PERFORM 8010-CALCULER-RESULTAT
           DISPLAY "PRODUITS: " WS-TOTAL-PRODUITS
           DISPLAY "CHARGES:  " WS-TOTAL-CHARGES
           COMPUTE WS-RESULTAT = WS-TOTAL-PRODUITS - WS-TOTAL-CHARGES
           DISPLAY "RESULTAT: " WS-RESULTAT.

       8010-CALCULER-RESULTAT.
           MOVE 701000 TO WS-NUM-COMPTE
           READ FICHIER-COMPTES
               NOT INVALID KEY COMPUTE WS-TOTAL-PRODUITS = WS-SOLDE-CREDIT - WS-SOLDE-DEBIT
           END-READ
           MOVE 601000 TO WS-NUM-COMPTE
           READ FICHIER-COMPTES
               NOT INVALID KEY COMPUTE WS-TOTAL-CHARGES = WS-SOLDE-DEBIT - WS-SOLDE-CREDIT
           END-READ.

       9000-LETTRAGE.
           DISPLAY "NUMERO ECRITURE: " ACCEPT WS-NUM-ECR-RECH
           MOVE WS-NUM-ECR-RECH TO WS-ECR-NUM
           READ FICHIER-JOURNAL
               INVALID KEY DISPLAY "NON TROUVEE"
               NOT INVALID KEY
                   DISPLAY "ACTUEL: " WS-ECR-LETTRAGE
                   DISPLAY "NOUVEAU: " ACCEPT WS-NEW-LETTRE
                   MOVE WS-NEW-LETTRE TO WS-ECR-LETTRAGE
                   REWRITE WS-ECRITURE
           END-READ.

       9100-TABLEAU-BORD.
           PERFORM 8010-CALCULER-RESULTAT
           DISPLAY "CHIFFRE D'AFFAIRES: " WS-TOTAL-PRODUITS.
           COMPUTE WS-CALC-TEMP = WS-TOTAL-PRODUITS - WS-TOTAL-CHARGES.
           DISPLAY "MARGE: " WS-CALC-TEMP.

       9999-FERMETURE.
           CLOSE FICHIER-COMPTES FICHIER-JOURNAL.
           DISPLAY "ARRET DU SYSTEME.".
