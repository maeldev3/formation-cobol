IDENTIFICATION DIVISION.
       PROGRAM-ID. FACTURATION.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CLIENTS
               ASSIGN TO "clients.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-CODE-CLIENT
               FILE STATUS IS WS-FS-CLI.
           
           SELECT FICHIER-FACTURES
               ASSIGN TO "factures.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-NUM-FACTURE
               FILE STATUS IS WS-FS-FAC.
           
           SELECT FICHIER-LIGNES-FACTURE
               ASSIGN TO "lignes.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-CLE-LIGNE
               FILE STATUS IS WS-FS-LIG.
           
           SELECT FICHIER-REGLEMENTS
               ASSIGN TO "reglements.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FS-REG.

       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-CLIENTS.
       01 REG-CLIENT.
           05 WS-CODE-CLIENT      PIC 9(6).
           05 WS-RAISON-SOCIALE   PIC X(40).
           05 WS-ADRESSE          PIC X(80).
           05 WS-CP               PIC X(10).
           05 WS-VILLE            PIC X(30).
           05 WS-TVA-INTRA        PIC X(15).
           05 WS-SOLDE-DU         PIC S9(12)V99.
           05 WS-ENCOURS          PIC 9(12)V99.
           05 WS-CATEGORIE        PIC X(15).
           05 WS-ACTIF            PIC X(1).

       FD FICHIER-FACTURES.
       01 REG-FACTURE.
           05 WS-NUM-FACTURE      PIC 9(8).
           05 WS-FACTURE-DATE     PIC 9(8).
           05 WS-CODE-CLIENT-FAC  PIC 9(6).
           05 WS-MONTANT-HT       PIC 9(12)V99.
           05 WS-MONTANT-TVA      PIC 9(12)V99.
           05 WS-MONTANT-TTC      PIC 9(12)V99.
           05 WS-STATUT           PIC X(10).
           05 WS-DATE-ECHEANCE    PIC 9(8).
           05 WS-DATE-PAIEMENT    PIC 9(8).
           05 WS-MODE-REGLEMENT   PIC X(20).

       FD FICHIER-LIGNES-FACTURE.
       01 REG-LIGNE.
           05 WS-CLE-LIGNE.
              10 WS-FACTURE-NUM   PIC 9(8).
              10 WS-LIGNE-NUM     PIC 9(3).
           05 WS-PRODUIT          PIC X(50).
           05 WS-QUANTITE         PIC 9(5).
           05 WS-PU-HT            PIC 9(7)V99.
           05 WS-TVA-TAUX         PIC 9(2)V99.
           05 WS-MONTANT-LIGNE    PIC 9(12)V99.

       FD FICHIER-REGLEMENTS.
       01 REG-REGLEMENT.
           05 WS-REG-NUM-FACTURE  PIC 9(8).
           05 WS-REG-DATE         PIC 9(8).
           05 WS-REG-MONTANT      PIC 9(12)V99.
           05 WS-REG-MODE         PIC X(20).
           05 WS-REG-REFERENCE    PIC X(20).

       WORKING-STORAGE SECTION.
       *> STATUS FILES
       01 WS-FS-CLI               PIC XX.
       01 WS-FS-FAC               PIC XX.
       01 WS-FS-LIG               PIC XX.
       01 WS-FS-REG               PIC XX.
       
       *> VARIABLES DE TRAVAIL
       01 WS-CHOIX                PIC 99.
       01 WS-QUITTER              PIC X(1) VALUE 'N'.
       01 WS-QUITTER-LIGNE        PIC X(1) VALUE 'N'.
       01 WS-NUM-FACTURE-COURANT  PIC 9(8) VALUE 10000.
       01 WS-NUM-FACTURE-RECH     PIC 9(8).
       01 WS-CODE-CLIENT-RECH     PIC 9(6).
       01 WS-NEW-RAISON           PIC X(40).
       01 WS-MONTANT-TVA-LIGNE    PIC 9(12)V99.
       01 WS-JOURS-RETARD         PIC S9(5).
       01 WS-CREANCE-CLIENT       PIC S9(12)V99.
       01 WS-DATE-DEBUT           PIC 9(8).
       01 WS-DATE-FIN             PIC 9(8).
       01 WS-CA-TOTAL             PIC 9(12)V99.
       01 WS-NUM-FACTURE-ORIG     PIC 9(8).
       01 WS-MOTIF                PIC X(40).

       01 WS-DATE-COURANTE.
           05 WS-DATE-ANNEE       PIC 9(4).
           05 WS-DATE-MOIS        PIC 9(2).
           05 WS-DATE-JOUR        PIC 9(2).

       PROCEDURE DIVISION.
           PERFORM 1000-INITIALISATION
           PERFORM UNTIL WS-QUITTER = 'O'
               PERFORM 2000-MENU-PRINCIPAL
               PERFORM 3000-TRAITER-MENU
           END-PERFORM
           PERFORM 9000-FERMETURE
           STOP RUN.

       1000-INITIALISATION.
           DISPLAY "======================================"
           DISPLAY "      SYSTEME DE FACTURATION"
           DISPLAY "======================================"
           MOVE FUNCTION CURRENT-DATE TO WS-DATE-COURANTE
           
           *> Initialisation Clients
           OPEN I-O FICHIER-CLIENTS
           IF WS-FS-CLI NOT = '00'
               OPEN OUTPUT FICHIER-CLIENTS
               CLOSE FICHIER-CLIENTS
               OPEN I-O FICHIER-CLIENTS
               PERFORM 1100-CHARGER-CLIENTS-TEST
           END-IF
           
           *> Initialisation Factures
           OPEN I-O FICHIER-FACTURES
           IF WS-FS-FAC NOT = '00'
               OPEN OUTPUT FICHIER-FACTURES
               CLOSE FICHIER-FACTURES
               OPEN I-O FICHIER-FACTURES
           END-IF
           
           *> Initialisation Lignes
           OPEN I-O FICHIER-LIGNES-FACTURE
           IF WS-FS-LIG NOT = '00'
               OPEN OUTPUT FICHIER-LIGNES-FACTURE
               CLOSE FICHIER-LIGNES-FACTURE
               OPEN I-O FICHIER-LIGNES-FACTURE
           END-IF
           
           *> Initialisation Reglements (Status 35 Fix)
           OPEN INPUT FICHIER-REGLEMENTS
           IF WS-FS-REG = '35'
               OPEN OUTPUT FICHIER-REGLEMENTS
               CLOSE FICHIER-REGLEMENTS
           ELSE
               CLOSE FICHIER-REGLEMENTS
           END-IF
           OPEN EXTEND FICHIER-REGLEMENTS.

       1100-CHARGER-CLIENTS-TEST.
           MOVE 1001 TO WS-CODE-CLIENT
           MOVE "SARL DUPONT ET FILS" TO WS-RAISON-SOCIALE
           MOVE 0 TO WS-SOLDE-DU WS-ENCOURS
           MOVE "O" TO WS-ACTIF
           WRITE REG-CLIENT.

       2000-MENU-PRINCIPAL.
           DISPLAY " "
           DISPLAY "=== MENU FACTURATION ==="
           DISPLAY "1. GESTION CLIENTS  2. CREER FACTURE  3. CONSULTER"
           DISPLAY "5. REGLEMENT       8. CA PERIODE      10. QUITTER"
           DISPLAY "CHOIX: " WITH NO ADVANCING
           ACCEPT WS-CHOIX.

       3000-TRAITER-MENU.
           EVALUATE WS-CHOIX
               WHEN 1  PERFORM 4000-GESTION-CLIENTS
               WHEN 2  PERFORM 5000-CREER-FACTURE
               WHEN 3  PERFORM 6000-CONSULTER-FACTURE
               WHEN 5  PERFORM 7000-ENREGISTRER-REGLEMENT
               WHEN 8  PERFORM 8200-CA-PAR-PERIODE
               WHEN 10 MOVE 'O' TO WS-QUITTER
               WHEN OTHER DISPLAY "NON IMPLEMENTE OU INVALIDE"
           END-EVALUATE.

       4000-GESTION-CLIENTS.
           DISPLAY "1. AJOUTER  2. LISTER"
           ACCEPT WS-CHOIX
           IF WS-CHOIX = 1 PERFORM 4100-AJOUTER-CLIENT END-IF
           IF WS-CHOIX = 2 PERFORM 4300-LISTER-CLIENTS END-IF.

       4100-AJOUTER-CLIENT.
           DISPLAY "CODE CLIENT: " WITH NO ADVANCING
           ACCEPT WS-CODE-CLIENT
           READ FICHIER-CLIENTS
               INVALID KEY
                   DISPLAY "RAISON SOCIALE: " WITH NO ADVANCING
                   ACCEPT WS-RAISON-SOCIALE
                   MOVE 0 TO WS-SOLDE-DU WS-ENCOURS
                   WRITE REG-CLIENT
                   DISPLAY "CLIENT AJOUTE"
               NOT INVALID KEY
                   DISPLAY "ERREUR: CLIENT EXISTANT"
           END-READ.

       4300-LISTER-CLIENTS.
           MOVE 0 TO WS-CODE-CLIENT
           START FICHIER-CLIENTS KEY IS NOT < WS-CODE-CLIENT
           PERFORM UNTIL WS-FS-CLI = '10'
               READ FICHIER-CLIENTS NEXT
                   AT END MOVE '10' TO WS-FS-CLI
                   NOT AT END
                       DISPLAY WS-CODE-CLIENT " | " WS-RAISON-SOCIALE
               END-READ
           END-PERFORM
           MOVE '00' TO WS-FS-CLI.

       5000-CREER-FACTURE.
           DISPLAY "CODE CLIENT: " WITH NO ADVANCING
           ACCEPT WS-CODE-CLIENT-RECH
           MOVE WS-CODE-CLIENT-RECH TO WS-CODE-CLIENT
           READ FICHIER-CLIENTS
               INVALID KEY DISPLAY "CLIENT INCONNU"
               NOT INVALID KEY
                   ADD 1 TO WS-NUM-FACTURE-COURANT
                   MOVE WS-NUM-FACTURE-COURANT TO WS-NUM-FACTURE
                   MOVE WS-DATE-COURANTE TO WS-FACTURE-DATE
                   MOVE WS-CODE-CLIENT-RECH TO WS-CODE-CLIENT-FAC
                   
                   MOVE 'N' TO WS-QUITTER-LIGNE
                   PERFORM 5100-SAISIR-LIGNES-FACTURE
                   
                   COMPUTE WS-MONTANT-TTC = WS-MONTANT-HT + WS-MONTANT-TVA
                   MOVE "EMISE" TO WS-STATUT
                   WRITE REG-FACTURE
                   
                   ADD WS-MONTANT-TTC TO WS-SOLDE-DU
                   REWRITE REG-CLIENT
                   DISPLAY "FACTURE CREEE N°" WS-NUM-FACTURE
           END-READ.

       5100-SAISIR-LIGNES-FACTURE.
           MOVE 0 TO WS-MONTANT-HT WS-MONTANT-TVA
           MOVE 1 TO WS-LIGNE-NUM
           PERFORM UNTIL WS-QUITTER-LIGNE = 'O'
               DISPLAY "PRODUIT (ENTREE POUR FIN): " WITH NO ADVANCING
               ACCEPT WS-PRODUIT
               IF WS-PRODUIT = SPACES
                   MOVE 'O' TO WS-QUITTER-LIGNE
               ELSE
                   DISPLAY "QUANTITE: " WITH NO ADVANCING
                   ACCEPT WS-QUANTITE
                   DISPLAY "PU HT: " WITH NO ADVANCING
                   ACCEPT WS-PU-HT
                   MOVE 20 TO WS-TVA-TAUX
                   
                   COMPUTE WS-MONTANT-LIGNE = WS-QUANTITE * WS-PU-HT
                   COMPUTE WS-MONTANT-TVA-LIGNE = WS-MONTANT-LIGNE * 0.20
                   
                   ADD WS-MONTANT-LIGNE TO WS-MONTANT-HT
                   ADD WS-MONTANT-TVA-LIGNE TO WS-MONTANT-TVA
                   
                   MOVE WS-NUM-FACTURE TO WS-FACTURE-NUM
                   WRITE REG-LIGNE
                   ADD 1 TO WS-LIGNE-NUM
               END-IF
           END-PERFORM.

       6000-CONSULTER-FACTURE.
           DISPLAY "NUMERO FACTURE: " WITH NO ADVANCING
           ACCEPT WS-NUM-FACTURE-RECH
           MOVE WS-NUM-FACTURE-RECH TO WS-NUM-FACTURE
           READ FICHIER-FACTURES
               INVALID KEY DISPLAY "INCONNUE"
               NOT INVALID KEY
                   DISPLAY "CLIENT: " WS-CODE-CLIENT-FAC
                   DISPLAY "TOTAL TTC: " WS-MONTANT-TTC
                   DISPLAY "STATUT: " WS-STATUT
           END-READ.

       7000-ENREGISTRER-REGLEMENT.
           DISPLAY "NUMERO FACTURE: " WITH NO ADVANCING
           ACCEPT WS-NUM-FACTURE-RECH
           MOVE WS-NUM-FACTURE-RECH TO WS-NUM-FACTURE
           READ FICHIER-FACTURES
               INVALID KEY DISPLAY "FACTURE NON TROUVEE"
               NOT INVALID KEY
                   IF WS-STATUT NOT = 'PAYEE'
                       MOVE WS-NUM-FACTURE TO WS-REG-NUM-FACTURE
                       MOVE WS-MONTANT-TTC TO WS-REG-MONTANT
                       MOVE WS-DATE-COURANTE TO WS-REG-DATE
                       WRITE REG-REGLEMENT
                       
                       MOVE "PAYEE" TO WS-STATUT
                       REWRITE REG-FACTURE
                       
                       MOVE WS-CODE-CLIENT-FAC TO WS-CODE-CLIENT
                       READ FICHIER-CLIENTS
                           SUBTRACT WS-REG-MONTANT FROM WS-SOLDE-DU
                           REWRITE REG-CLIENT
                       END-READ
                       DISPLAY "REGLEMENT VALIDE"
                   ELSE
                       DISPLAY "DEJA PAYEE"
                   END-IF
           END-READ.

       8200-CA-PAR-PERIODE.
           MOVE 0 TO WS-CA-TOTAL
           MOVE 0 TO WS-NUM-FACTURE
           START FICHIER-FACTURES KEY IS NOT < WS-NUM-FACTURE
           PERFORM UNTIL WS-FS-FAC = '10'
               READ FICHIER-FACTURES NEXT
                   AT END MOVE '10' TO WS-FS-FAC
                   NOT AT END
                       ADD WS-MONTANT-TTC TO WS-CA-TOTAL
               END-READ
           END-PERFORM
           DISPLAY "CHIFFRE D'AFFAIRES TOTAL: " WS-CA-TOTAL
           MOVE '00' TO WS-FS-FAC.

       9000-FERMETURE.
           CLOSE FICHIER-CLIENTS FICHIER-FACTURES 
                 FICHIER-LIGNES-FACTURE FICHIER-REGLEMENTS.
           DISPLAY "SYSTÈME ARRETÉ.".
