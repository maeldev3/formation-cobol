IDENTIFICATION DIVISION.
       PROGRAM-ID. GESTION-STOCK.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-PRODUITS
               ASSIGN TO "stock.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-CODE-PROD
               FILE STATUS IS WS-FS.
           
           SELECT FICHIER-MOUVEMENTS
               ASSIGN TO "mouvements.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FS-MVT.

       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-PRODUITS.
       01 REG-PRODUIT.
           05 WS-CODE-PROD      PIC X(8).
           05 WS-DESIGNATION    PIC X(40).
           05 WS-CATEGORIE      PIC X(15).
           05 WS-STOCK-ACTUEL   PIC 9(6).
           05 WS-STOCK-MIN      PIC 9(6).
           05 WS-STOCK-MAX      PIC 9(6).
           05 WS-PRIX-ACHAT     PIC 9(7)V99.
           05 WS-PRIX-VENTE     PIC 9(7)V99.
           05 WS-FOURNISSEUR    PIC X(30).
           05 WS-EMPLACEMENT    PIC X(10).
           05 WS-DERNIER-MVT    PIC 9(8).

       FD FICHIER-MOUVEMENTS.
       01 REG-MOUVEMENT.
           05 WS-MVT-CODE       PIC X(8).
           05 WS-MVT-DATE       PIC 9(8).
           05 WS-MVT-TYPE       PIC X(10).
           05 WS-MVT-QTE        PIC 9(6).
           05 WS-MVT-MOTIF      PIC X(50).

       WORKING-STORAGE SECTION.
       01 WS-FS                 PIC XX.
       01 WS-FS-MVT             PIC XX.
       01 WS-CHOIX              PIC 99.
       01 WS-QUITTER            PIC X(1) VALUE 'N'.
       01 WS-CODE-RECHERCHE     PIC X(8).
       
       *> Variables de saisie temporaires
       01 WS-NEW-DESIGNATION    PIC X(40).
       01 WS-NEW-PRIX           PIC 9(7)V99.
       01 WS-CONFIRM            PIC X(1).
       
       *> Variables de calcul
       01 WS-QTE-MOUVEMENT      PIC 9(6).
       01 WS-VALEUR-STOCK       PIC 9(12)V99.
       01 WS-NB-PRODUITS        PIC 9(4) VALUE 0.
       01 WS-STOCK-PHYSIQUE     PIC 9(6).
       01 WS-ECART              PIC S9(6).
       01 WS-VENTES-ANNUEL      PIC 9(6).
       01 WS-ROTATION           PIC 9(3)V99.
       01 WS-MARGE-PCT          PIC 9(3)V99.
       01 WS-SOMME-MARGE        PIC 9(10)V99.
       01 WS-MARGE-MOY          PIC 9(3)V99.
       01 WS-QTE-COMMANDE       PIC 9(6).
       
       *> Variables de recherche
       01 WS-RECH-DESIGNATION   PIC X(20).
       01 WS-RECH-CATEGORIE     PIC X(15).
       01 WS-RECH-EMPLACEMENT   PIC X(10).

       01 WS-ALERTES.
           05 WS-ALERTE OCCURS 20 TIMES.
               10 WS-ALERTE-CODE PIC X(8).
               10 WS-ALERTE-QTE  PIC 9(6).
               10 WS-ALERTE-STATUT PIC X(10).
       01 WS-NB-ALERTES          PIC 9(2) VALUE 0.
       01 WS-I                  PIC 9(3).

       01 WS-DATE-COURANTE.
           05 WS-DATE-ANNEE      PIC 9(4).
           05 WS-DATE-MOIS       PIC 9(2).
           05 WS-DATE-JOUR       PIC 9(2).

       PROCEDURE DIVISION.
       MAIN-LOGIC.
           PERFORM 1000-INITIALISATION
           PERFORM UNTIL WS-QUITTER = 'O'
               PERFORM 2000-AFFICHER-MENU
               PERFORM 3000-TRAITER-MENU
           END-PERFORM
           PERFORM 9000-FERMETURE
           STOP RUN.

       1000-INITIALISATION.
           DISPLAY "======================================"
           DISPLAY "   SYSTEME DE GESTION DE STOCK"
           DISPLAY "======================================"
           MOVE FUNCTION CURRENT-DATE(1:8) TO WS-DATE-COURANTE
           
           OPEN I-O FICHIER-PRODUITS
           IF WS-FS NOT = '00'
               OPEN OUTPUT FICHIER-PRODUITS
               CLOSE FICHIER-PRODUITS
               OPEN I-O FICHIER-PRODUITS
           END-IF
           OPEN EXTEND FICHIER-MOUVEMENTS.

       2000-AFFICHER-MENU.
           DISPLAY " "
           DISPLAY "=== MENU PRINCIPAL ==="
           DISPLAY "1. GESTION PRODUITS  2. ENTREE STOCK  3. SORTIE"
           DISPLAY "4. INVENTAIRE        5. VALEUR STOCK  6. ALERTES"
           DISPLAY "13. QUITTER"
           DISPLAY "CHOIX: " WITH NO ADVANCING
           ACCEPT WS-CHOIX.

       3000-TRAITER-MENU.
           EVALUATE WS-CHOIX
               WHEN 1  PERFORM 4000-GESTION-PRODUITS
               WHEN 2  PERFORM 5000-ENTREE-STOCK
               WHEN 3  PERFORM 6000-SORTIE-STOCK
               WHEN 5  PERFORM 8010-VALEUR-TOTALE
               WHEN 6  PERFORM 8100-ALERTES-STOCK
               WHEN 13 MOVE 'O' TO WS-QUITTER
               WHEN OTHER DISPLAY "NON IMPLEMENTE OU INVALIDE"
           END-EVALUATE.

       4000-GESTION-PRODUITS.
           DISPLAY "1. AJOUTER  2. LISTER"
           ACCEPT WS-CHOIX
           IF WS-CHOIX = 1 PERFORM 4100-AJOUTER-PRODUIT END-IF
           IF WS-CHOIX = 2 PERFORM 4400-LISTER-PRODUITS END-IF.

       4100-AJOUTER-PRODUIT.
           DISPLAY "CODE: " ACCEPT WS-CODE-PROD
           READ FICHIER-PRODUITS
               INVALID KEY
                   DISPLAY "DESIGNATION: " ACCEPT WS-DESIGNATION
                   DISPLAY "PRIX ACHAT: "  ACCEPT WS-PRIX-ACHAT
                   MOVE 0 TO WS-STOCK-ACTUEL
                   WRITE REG-PRODUIT
                       INVALID KEY DISPLAY "ERREUR ECRITURE"
                   END-WRITE
               NOT INVALID KEY
                   DISPLAY "EXISTE DEJA !"
           END-READ.

       4400-LISTER-PRODUITS.
           MOVE LOW-VALUES TO WS-CODE-PROD
           START FICHIER-PRODUITS KEY IS NOT < WS-CODE-PROD
           PERFORM UNTIL WS-FS = '10'
               READ FICHIER-PRODUITS NEXT
                   AT END MOVE '10' TO WS-FS
                   NOT AT END
                       DISPLAY WS-CODE-PROD " | " WS-DESIGNATION 
                               " | QTE: " WS-STOCK-ACTUEL
               END-READ
           END-PERFORM
           MOVE '00' TO WS-FS.

       5000-ENTREE-STOCK.
           DISPLAY "CODE PRODUIT: " ACCEPT WS-CODE-PROD
           READ FICHIER-PRODUITS
               INVALID KEY DISPLAY "INCONNU"
               NOT INVALID KEY
                   DISPLAY "QTE A AJOUTER: " ACCEPT WS-QTE-MOUVEMENT
                   ADD WS-QTE-MOUVEMENT TO WS-STOCK-ACTUEL
                   REWRITE REG-PRODUIT
                   DISPLAY "OK. NOUVEAU STOCK: " WS-STOCK-ACTUEL
           END-READ.

       6000-SORTIE-STOCK.
           DISPLAY "CODE PRODUIT: " ACCEPT WS-CODE-PROD
           READ FICHIER-PRODUITS
               INVALID KEY DISPLAY "INCONNU"
               NOT INVALID KEY
                   DISPLAY "QTE A RETIRER: " ACCEPT WS-QTE-MOUVEMENT
                   IF WS-QTE-MOUVEMENT <= WS-STOCK-ACTUEL
                       SUBTRACT WS-QTE-MOUVEMENT FROM WS-STOCK-ACTUEL
                       REWRITE REG-PRODUIT
                       DISPLAY "SORTIE OK"
                   ELSE
                       DISPLAY "STOCK INSUFFISANT"
                   END-IF
           END-READ.

       8010-VALEUR-TOTALE.
           MOVE 0 TO WS-VALEUR-STOCK
           MOVE LOW-VALUES TO WS-CODE-PROD
           START FICHIER-PRODUITS KEY IS NOT < WS-CODE-PROD
           PERFORM UNTIL WS-FS = '10'
               READ FICHIER-PRODUITS NEXT
                   AT END MOVE '10' TO WS-FS
                   NOT AT END
                       COMPUTE WS-VALEUR-STOCK = WS-VALEUR-STOCK +
                           (WS-STOCK-ACTUEL * WS-PRIX-ACHAT)
               END-READ
           END-PERFORM
           DISPLAY "VALEUR TOTALE DU STOCK: " WS-VALEUR-STOCK
           MOVE '00' TO WS-FS.

       8100-ALERTES-STOCK.
           DISPLAY "--- PRODUITS SOUS LE SEUIL MIN ---"
           MOVE LOW-VALUES TO WS-CODE-PROD
           START FICHIER-PRODUITS KEY IS NOT < WS-CODE-PROD
           PERFORM UNTIL WS-FS = '10'
               READ FICHIER-PRODUITS NEXT
                   AT END MOVE '10' TO WS-FS
                   NOT AT END
                       IF WS-STOCK-ACTUEL < WS-STOCK-MIN
                           DISPLAY WS-CODE-PROD " ALERTE ! Reste: " 
                                   WS-STOCK-ACTUEL
                       END-IF
               END-READ
           END-PERFORM
           MOVE '00' TO WS-FS.

       9000-FERMETURE.
           CLOSE FICHIER-PRODUITS
           CLOSE FICHIER-MOUVEMENTS
           DISPLAY "AU REVOIR".
