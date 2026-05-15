       IDENTIFICATION DIVISION.
       PROGRAM-ID. MULTI-DEPOTS.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-DEPOTS
               ASSIGN TO "depots.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-CODE-DEPOT
               FILE STATUS IS WS-FS-DEP.
           
           SELECT FICHIER-STOCKS
               ASSIGN TO "stocks.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-DEPOT-CODE, WS-PROD-CODE
               FILE STATUS IS WS-FS-STK.
           
           SELECT FICHIER-TRANSFERTS
               ASSIGN TO "transferts.dat"
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-DEPOTS.
       01 WS-DEPOT.
           05 WS-CODE-DEPOT       PIC X(10).
           05 WS-NOM-DEPOT        PIC X(40).
           05 WS-ADRESSE-DEPOT    PIC X(80).
           05 WS-VILLE-DEPOT      PIC X(30).
           05 WS-CAPACITE-MAX     PIC 9(9).
           05 WS-CAPACITE-USEE    PIC 9(9).
           05 WS-RESPONSABLE      PIC X(30).
           05 WS-TELEPHONE        PIC X(15).
           05 WS-ACTIF-DEPOT      PIC X(1) VALUE 'O'.
       
       FD FICHIER-STOCKS.
       01 WS-STOCK.
           05 WS-DEPOT-CODE       PIC X(10).
           05 WS-PROD-CODE        PIC X(10).
           05 WS-QUANTITE-STOCK   PIC 9(9).
           05 WS-QUANTITE-MIN     PIC 9(9).
           05 WS-QUANTITE-MAX     PIC 9(9).
           05 WS-EMPLACEMENT      PIC X(10).
           05 WS-DERNIER-MVT      PIC 9(8).
           05 WS-EN-COURS         PIC 9(9).
       
       FD FICHIER-TRANSFERTS.
       01 WS-TRANSFERT.
           05 WS-TRANSFERT-ID     PIC 9(8).
           05 WS-TRANSFERT-DATE   PIC 9(8).
           05 WS-DEPOT-ORIGINE    PIC X(10).
           05 WS-DEPOT-DEST       PIC X(10).
           05 WS-PROD-TRANSFERT   PIC X(10).
           05 WS-QUANTITE-TRANSF  PIC 9(9).
           05 WS-STATUT-TRANSF    PIC X(10).
              88 TRANSFERT-PLANIFIE VALUE 'PLANIFIE'.
              88 TRANSFERT-ENCOURS VALUE 'EN COURS'.
              88 TRANSFERT-TERMINE VALUE 'TERMINE'.
           05 WS-MOTIF-TRANSF     PIC X(50).
       
       WORKING-STORAGE SECTION.
       01 WS-FS-DEP               PIC XX.
       01 WS-FS-STK               PIC XX.
       01 WS-CHOIX                PIC 9.
       01 WS-QUITTER-INV          PIC X(1) VALUE 'N'.
       01 WS-I                    PIC 9(4).
       01 WS-DATE-COURANTE-INV.
           05 WS-INV-JOUR         PIC 9(2).
           05 WS-INV-MOIS         PIC 9(2).
           05 WS-INV-ANNEE        PIC 9(4).
       
       01 WS-ZONES-TRAVAIL.
           05 WS-DEPOT-RECH       PIC X(10).
           05 WS-PROD-RECH        PIC X(10).
           05 WS-QUANTITE-MVT     PIC 9(9).
           05 WS-STATUT-OK        PIC X(1).
           05 WS-TRANSFERT-NUM    PIC 9(8) VALUE 10000.
       
       PROCEDURE DIVISION.
           PERFORM 1000-INIT-INVENTORY
           PERFORM UNTIL WS-QUITTER-INV = 'O'
               PERFORM 2000-MENU-INVENTORY
               PERFORM 3000-TRAITER-INVENTORY
           END-PERFORM
           PERFORM 9000-FERMER-INVENTORY
           STOP RUN.
       
       1000-INIT-INVENTORY.
           DISPLAY "======================================"
           DISPLAY "    SYSTÈME D'INVENTAIRE MULTI-DÉPÔTS"
           DISPLAY "    GESTION CENTRALISÉE DES STOCKS"
           DISPLAY "======================================"
           
           MOVE FUNCTION CURRENT-DATE TO WS-DATE-COURANTE-INV
           
           OPEN I-O FICHIER-DEPOTS
           IF WS-FS-DEP NOT = '00'
               OPEN OUTPUT FICHIER-DEPOTS
               CLOSE FICHIER-DEPOTS
               OPEN I-O FICHIER-DEPOTS
               PERFORM 1100-CHARGER-DEPOTS
           END-IF
           
           OPEN I-O FICHIER-STOCKS
           IF WS-FS-STK NOT = '00'
               OPEN OUTPUT FICHIER-STOCKS
               CLOSE FICHIER-STOCKS
               OPEN I-O FICHIER-STOCKS
           END-IF
           
           OPEN EXTEND FICHIER-TRANSFERTS
           .
       
       1100-CHARGER-DEPOTS.
           MOVE "DEP001" TO WS-CODE-DEPOT
           MOVE "DEPOT PARIS NORD" TO WS-NOM-DEPOT
           MOVE "12 RUE DE PARIS" TO WS-ADRESSE-DEPOT
           MOVE "PARIS" TO WS-VILLE-DEPOT
           MOVE 10000 TO WS-CAPACITE-MAX
           MOVE 0 TO WS-CAPACITE-USEE
           MOVE "JEAN DUPONT" TO WS-RESPONSABLE
           MOVE "0145678901" TO WS-TELEPHONE
           WRITE WS-DEPOT
           
           MOVE "DEP002" TO WS-CODE-DEPOT
           MOVE "DEPOT LYON SUD" TO WS-NOM-DEPOT
           MOVE "45 AVENUE DES LYONNAIS" TO WS-ADRESSE-DEPOT
           MOVE "LYON" TO WS-VILLE-DEPOT
           MOVE 8000 TO WS-CAPACITE-MAX
           MOVE 0 TO WS-CAPACITE-USEE
           MOVE "SOPHIE MARTIN" TO WS-RESPONSABLE
           MOVE "0445678901" TO WS-TELEPHONE
           WRITE WS-DEPOT
           
           MOVE "DEP003" TO WS-CODE-DEPOT
           MOVE "DEPOT MARSEILLE" TO WS-NOM-DEPOT
           MOVE "78 RUE DE MARSEILLE" TO WS-ADRESSE-DEPOT
           MOVE "MARSEILLE" TO WS-VILLE-DEPOT
           MOVE 5000 TO WS-CAPACITE-MAX
           MOVE 0 TO WS-CAPACITE-USEE
           MOVE "PIERRE DURAND" TO WS-RESPONSABLE
           MOVE "0445678902" TO WS-TELEPHONE
           WRITE WS-DEPOT
           .
       
       2000-MENU-INVENTORY.
           DISPLAY " "
           DISPLAY "=== MENU INVENTAIRE MULTI-DÉPÔTS ==="
           DISPLAY "1.  GESTION DES DÉPÔTS"
           DISPLAY "2.  CONSULTER STOCK"
           DISPLAY "3.  ENTRÉE DE MARCHANDISES"
           DISPLAY "4.  SORTIE DE MARCHANDISES"
           DISPLAY "5.  TRANSFERT ENTRE DÉPÔTS"
           DISPLAY "6.  INVENTAIRE PHYSIQUE"
           DISPLAY "7.  RAPPORT DE STOCK"
           DISPLAY "8.  ALERTES STOCK"
           DISPLAY "9.  TABLEAU DE BORD"
           DISPLAY "10. QUITTER"
           DISPLAY "CHOIX: "
           ACCEPT WS-CHOIX
           .
       
       3000-TRAITER-INVENTORY.
           EVALUATE WS-CHOIX
               WHEN 1  PERFORM 4000-GESTION-DEPOTS
               WHEN 2  PERFORM 5000-CONSULTER-STOCK
               WHEN 3  PERFORM 6000-ENTREE-STOCK
               WHEN 4  PERFORM 7000-SORTIE-STOCK
               WHEN 5  PERFORM 8000-TRANSFERT-STOCK
               WHEN 6  PERFORM 8100-INVENTAIRE-PHYSIQUE
               WHEN 7  PERFORM 8200-RAPPORT-STOCK
               WHEN 8  PERFORM 8300-ALERTES-STOCK-MULTI
               WHEN 9  PERFORM 8400-TABLEAU-BORD-STOCK
               WHEN 10 MOVE 'O' TO WS-QUITTER-INV
               WHEN OTHER DISPLAY "CHOIX INVALIDE"
           END-EVALUATE
           .
       
       4000-GESTION-DEPOTS.
           DISPLAY "--- GESTION DÉPÔTS ---"
           DISPLAY "1. AJOUTER DÉPÔT"
           DISPLAY "2. MODIFIER DÉPÔT"
           DISPLAY "3. LISTER DÉPÔTS"
           DISPLAY "4. CONSULTER DÉPÔT"
           ACCEPT WS-CHOIX
           
           EVALUATE WS-CHOIX
               WHEN 1 PERFORM 4100-AJOUTER-DEPOT
               WHEN 2 PERFORM 4200-MODIFIER-DEPOT
               WHEN 3 PERFORM 4300-LISTER-DEPOTS
               WHEN 4 PERFORM 4400-CONSULTER-DEPOT
           END-EVALUATE
           .
       
       4100-AJOUTER-DEPOT.
           DISPLAY "--- AJOUTER DÉPÔT ---"
           DISPLAY "CODE DÉPÔT (ex: DEP001): "
           ACCEPT WS-CODE-DEPOT
           
           READ FICHIER-DEPOTS
               INVALID KEY
                   DISPLAY "NOM DÉPÔT: "
                   ACCEPT WS-NOM-DEPOT
                   DISPLAY "ADRESSE: "
                   ACCEPT WS-ADRESSE-DEPOT
                   DISPLAY "VILLE: "
                   ACCEPT WS-VILLE-DEPOT
                   DISPLAY "CAPACITÉ MAXIMALE: "
                   ACCEPT WS-CAPACITE-MAX
                   DISPLAY "RESPONSABLE: "
                   ACCEPT WS-RESPONSABLE
                   DISPLAY "TÉLÉPHONE: "
                   ACCEPT WS-TELEPHONE
                   MOVE 0 TO WS-CAPACITE-USEE
                   MOVE 'O' TO WS-ACTIF-DEPOT
                   WRITE WS-DEPOT
                   DISPLAY "DÉPÔT AJOUTÉ"
               NOT INVALID KEY
                   DISPLAY "CODE DÉPÔT EXISTANT"
           END-READ
           .
       
       4200-MODIFIER-DEPOT.
           DISPLAY "CODE DÉPÔT: "
           ACCEPT WS-DEPOT-RECH
           MOVE WS-DEPOT-RECH TO WS-CODE-DEPOT
           
           READ FICHIER-DEPOTS
               INVALID KEY
                   DISPLAY "DÉPÔT NON TROUVÉ"
               NOT INVALID KEY
                   DISPLAY "NOUVEAU NOM (" 
                           FUNCTION TRIM(WS-NOM-DEPOT) "): "
                   ACCEPT WS-NEW-NOM
                   IF WS-NEW-NOM NOT = SPACES
                       MOVE WS-NEW-NOM TO WS-NOM-DEPOT
                   END-IF
                   
                   DISPLAY "NOUVEAU RESPONSABLE (" 
                           WS-RESPONSABLE "): "
                   ACCEPT WS-NEW-RESP
                   IF WS-NEW-RESP NOT = SPACES
                       MOVE WS-NEW-RESP TO WS-RESPONSABLE
                   END-IF
                   
                   REWRITE WS-DEPOT
                   DISPLAY "DÉPÔT MODIFIÉ"
           END-READ
           .
       
       4300-LISTER-DEPOTS.
           DISPLAY "=== LISTE DES DÉPÔTS ==="
           DISPLAY "CODE    | NOM DÉPÔT                  | CAPACITÉ | OCCUPATION"
           DISPLAY "--------+----------------------------+----------+-----------"
           
           MOVE SPACES TO WS-CODE-DEPOT
           START FICHIER-DEPOTS KEY IS NOT < WS-CODE-DEPOT
           
           PERFORM UNTIL WS-FS-DEP = '10'
               READ FICHIER-DEPOTS NEXT
                   AT END
                       MOVE '10' TO WS-FS-DEP
                   NOT AT END
                       COMPUTE WS-TAUX-OCC = 
                           (WS-CAPACITE-USEE * 100) / 
                           WS-CAPACITE-MAX
                       DISPLAY WS-CODE-DEPOT " | "
                               FUNCTION TRIM(WS-NOM-DEPOT)
                               SPACE(27 - FUNCTION LENGTH(
                               FUNCTION TRIM(WS-NOM-DEPOT)))
                               " | " 
                               WS-CAPACITE-USEE "/"
                               WS-CAPACITE-MAX " | "
                               WS-TAUX-OCC "%"
               END-READ
           END-PERFORM
           .
       
       4400-CONSULTER-DEPOT.
           DISPLAY "CODE DÉPÔT: "
           ACCEPT WS-DEPOT-RECH
           MOVE WS-DEPOT-RECH TO WS-CODE-DEPOT
           
           READ FICHIER-DEPOTS
               INVALID KEY
                   DISPLAY "DÉPÔT NON TROUVÉ"
               NOT INVALID KEY
                   DISPLAY " "
                   DISPLAY "=== INFORMATIONS DÉPÔT ==="
                   DISPLAY "CODE: " WS-CODE-DEPOT
                   DISPLAY "NOM: " FUNCTION TRIM(WS-NOM-DEPOT)
                   DISPLAY "ADRESSE: " 
                           FUNCTION TRIM(WS-ADRESSE-DEPOT)
                   DISPLAY "VILLE: " FUNCTION TRIM(WS-VILLE-DEPOT)
                   DISPLAY "CAPACITÉ: " WS-CAPACITE-USEE "/"
                           WS-CAPACITE-MAX
                   DISPLAY "RESPONSABLE: " WS-RESPONSABLE
                   DISPLAY "TÉLÉPHONE: " WS-TELEPHONE
                   PERFORM 4410-LISTER-STOCK-DEPOT
           END-READ
           .
       
       4410-LISTER-STOCK-DEPOT.
           DISPLAY " "
           DISPLAY "--- STOCK DANS LE DÉPÔT ---"
           DISPLAY "PRODUIT    | QUANTITÉ | MIN | MAX"
           DISPLAY "-----------+----------+-----+-----"
           
           MOVE WS-CODE-DEPOT TO WS-DEPOT-CODE
           MOVE SPACES TO WS-PROD-CODE
           START FICHIER-STOCKS 
               KEY IS NOT < WS-DEPOT-CODE
           
           PERFORM UNTIL WS-FS-STK = '10'
               READ FICHIER-STOCKS NEXT
                   AT END
                       MOVE '10' TO WS-FS-STK
                   NOT AT END
                       IF WS-DEPOT-CODE = WS-CODE-DEPOT
                           DISPLAY WS-PROD-CODE " | "
                                   WS-QUANTITE-STOCK " | "
                                   WS-QUANTITE-MIN " | "
                                   WS-QUANTITE-MAX
                       END-IF
               END-READ
           END-PERFORM
           .
       
       5000-CONSULTER-STOCK.
           DISPLAY "--- CONSULTER STOCK ---"
           DISPLAY "CODE PRODUIT: "
           ACCEPT WS-PROD-RECH
           
           DISPLAY " "
           DISPLAY "STOCK DU PRODUIT " WS-PROD-RECH
           DISPLAY "DÉPÔT      | QUANTITÉ | MIN | MAX | SITUATION"
           DISPLAY "-----------+----------+-----+-----+-------------"
           
           MOVE SPACES TO WS-DEPOT-CODE
           START FICHIER-STOCKS 
               KEY IS NOT < WS-DEPOT-CODE
           
           PERFORM UNTIL WS-FS-STK = '10'
               READ FICHIER-STOCKS NEXT
                   AT END
                       MOVE '10' TO WS-FS-STK
                   NOT AT END
                       IF WS-PROD-CODE = WS-PROD-RECH
                           MOVE WS-DEPOT-CODE TO WS-CODE-DEPOT
                           READ FICHIER-DEPOTS
                               NOT INVALID KEY
                                   IF WS-QUANTITE-STOCK 
                                      <= WS-QUANTITE-MIN
                                       DISPLAY WS-DEPOT-CODE " | "
                                               WS-QUANTITE-STOCK " | "
                                               WS-QUANTITE-MIN " | "
                                               WS-QUANTITE-MAX " | "
                                               "ALERTE STOCK BAS"
                                   ELSE
                                       DISPLAY WS-DEPOT-CODE " | "
                                               WS-QUANTITE-STOCK " | "
                                               WS-QUANTITE-MIN " | "
                                               WS-QUANTITE-MAX " | "
                                               "OK"
                                   END-IF
                               END-READ
                       END-IF
               END-READ
           END-PERFORM
           .
       
       6000-ENTREE-STOCK.
           DISPLAY "--- ENTRÉE DE MARCHANDISES ---"
           DISPLAY "CODE DÉPÔT: "
           ACCEPT WS-DEPOT-RECH
           DISPLAY "CODE PRODUIT: "
           ACCEPT WS-PROD-RECH
           DISPLAY "QUANTITÉ À AJOUTER: "
           ACCEPT WS-QUANTITE-MVT
           
           MOVE WS-DEPOT-RECH TO WS-DEPOT-CODE
           MOVE WS-PROD-RECH TO WS-PROD-CODE
           
           READ FICHIER-STOCKS
               INVALID KEY
                   *> CRÉER NOUVEAU PRODUIT DANS LE DÉPÔT
                   MOVE WS-DEPOT-RECH TO WS-DEPOT-CODE
                   MOVE WS-PROD-RECH TO WS-PROD-CODE
                   MOVE WS-QUANTITE-MVT TO WS-QUANTITE-STOCK
                   MOVE 10 TO WS-QUANTITE-MIN
                   MOVE 1000 TO WS-QUANTITE-MAX
                   MOVE "A1-B2" TO WS-EMPLACEMENT
                   MOVE WS-DATE-COURANTE-INV TO WS-DERNIER-MVT
                   MOVE 0 TO WS-EN-COURS
                   WRITE WS-STOCK
               NOT INVALID KEY
                   ADD WS-QUANTITE-MVT TO WS-QUANTITE-STOCK
                   IF WS-QUANTITE-STOCK > WS-QUANTITE-MAX
                       DISPLAY "ATTENTION: DÉPASSEMENT STOCK MAX!"
                   END-IF
                   REWRITE WS-STOCK
           END-READ
           
           *> METTRE À JOUR CAPACITÉ DÉPÔT
           MOVE WS-DEPOT-RECH TO WS-CODE-DEPOT
           READ FICHIER-DEPOTS
               NOT INVALID KEY
                   ADD WS-QUANTITE-MVT TO WS-CAPACITE-USEE
                   REWRITE WS-DEPOT
           END-READ
           
           DISPLAY "ENTRÉE EFFECTUÉE"
           .
       
       7000-SORTIE-STOCK.
           DISPLAY "--- SORTIE DE MARCHANDISES ---"
           DISPLAY "CODE DÉPÔT: "
           ACCEPT WS-DEPOT-RECH
           DISPLAY "CODE PRODUIT: "
           ACCEPT WS-PROD-RECH
           DISPLAY "QUANTITÉ À RETIRER: "
           ACCEPT WS-QUANTITE-MVT
           
           MOVE WS-DEPOT-RECH TO WS-DEPOT-CODE
           MOVE WS-PROD-RECH TO WS-PROD-CODE
           
           READ FICHIER-STOCKS
               INVALID KEY
                   DISPLAY "PRODUIT NON TROUVÉ DANS CE DÉPÔT"
               NOT INVALID KEY
                   IF WS-QUANTITE-STOCK >= WS-QUANTITE-MVT
                       SUBTRACT WS-QUANTITE-MVT 
                         FROM WS-QUANTITE-STOCK
                       REWRITE WS-STOCK
                       
                       *> METTRE À JOUR CAPACITÉ DÉPÔT
                       MOVE WS-DEPOT-RECH TO WS-CODE-DEPOT
                       READ FICHIER-DEPOTS
                           NOT INVALID KEY
                               SUBTRACT WS-QUANTITE-MVT 
                                 FROM WS-CAPACITE-USEE
                               REWRITE WS-DEPOT
                       END-READ
                       
                       DISPLAY "SORTIE EFFECTUÉE"
                       
                       IF WS-QUANTITE-STOCK < WS-QUANTITE-MIN
                           DISPLAY "ALERTE: STOCK BAS DANS DÉPÔT " 
                                   WS-DEPOT-RECH
                       END-IF
                   ELSE
                       DISPLAY "STOCK INSUFFISANT! DISPONIBLE: " 
                               WS-QUANTITE-STOCK
                   END-IF
           END-READ
           .
       
       8000-TRANSFERT-STOCK.
           DISPLAY "--- TRANSFERT ENTRE DÉPÔTS ---"
           DISPLAY "PRODUIT À TRANSFÉRER: "
           ACCEPT WS-PROD-RECH
           DISPLAY "QUANTITÉ: "
           ACCEPT WS-QUANTITE-TRANSF
           DISPLAY "DÉPÔT ORIGINE: "
           ACCEPT WS-DEPOT-ORIG
           DISPLAY "DÉPÔT DESTINATION: "
           ACCEPT WS-DEPOT-DEST
           
           *> VÉRIFIER STOCK DANS DÉPÔT ORIGINE
           MOVE WS-DEPOT-ORIG TO WS-DEPOT-CODE
           MOVE WS-PROD-RECH TO WS-PROD-CODE
           
           READ FICHIER-STOCKS
               INVALID KEY
                   DISPLAY "PRODUIT NON TROUVÉ DANS DÉPÔT ORIGINE"
                   MOVE 'N' TO WS-STATUT-OK
               NOT INVALID KEY
                   IF WS-QUANTITE-STOCK >= WS-QUANTITE-TRANSF
                       MOVE 'O' TO WS-STATUT-OK
                   ELSE
                       DISPLAY "STOCK INSUFFISANT DANS DÉPÔT ORIGINE"
                       MOVE 'N' TO WS-STATUT-OK
                   END-IF
           END-READ
           
           IF WS-STATUT-OK = 'O'
               *> DÉDUIRE DE L'ORIGINE
               SUBTRACT WS-QUANTITE-TRANSF 
                 FROM WS-QUANTITE-STOCK
               REWRITE WS-STOCK
               
               *> AJOUTER À LA DESTINATION
               MOVE WS-DEPOT-DEST TO WS-DEPOT-CODE
               READ FICHIER-STOCKS
                   INVALID KEY
                       MOVE WS-DEPOT-DEST TO WS-DEPOT-CODE
                       MOVE WS-PROD-RECH TO WS-PROD-CODE
                       MOVE WS-QUANTITE-TRANSF 
                         TO WS-QUANTITE-STOCK
                       MOVE 10 TO WS-QUANTITE-MIN
                       MOVE 1000 TO WS-QUANTITE-MAX
                       WRITE WS-STOCK
                   NOT INVALID KEY
                       ADD WS-QUANTITE-TRANSF 
                         TO WS-QUANTITE-STOCK
                       REWRITE WS-STOCK
               END-READ
               
               *> ENREGISTRER LE TRANSFERT
               ADD 1 TO WS-TRANSFERT-NUM
               MOVE WS-TRANSFERT-NUM TO WS-TRANSFERT-ID
               MOVE WS-DATE-COURANTE-INV TO WS-TRANSFERT-DATE
               MOVE WS-DEPOT-ORIG TO WS-DEPOT-ORIGINE
               MOVE WS-DEPOT-DEST TO WS-DEPOT-DEST
               MOVE WS-PROD-RECH TO WS-PROD-TRANSFERT
               MOVE WS-QUANTITE-TRANSF TO WS-QUANTITE-TRANSF
               MOVE "TERMINE" TO WS-STATUT-TRANSF
               MOVE "TRANSFERT STOCK" TO WS-MOTIF-TRANSF
               WRITE WS-TRANSFERT
               
               DISPLAY "TRANSFERT EFFECTUÉ AVEC SUCCÈS"
               DISPLAY "N° TRANSFERT: " WS-TRANSFERT-NUM
           END-IF
           .
       
       8100-INVENTAIRE-PHYSIQUE.
           DISPLAY "--- INVENTAIRE PHYSIQUE ---"
           DISPLAY "CODE DÉPÔT: "
           ACCEPT WS-DEPOT-RECH
           
           DISPLAY "INVENTAIRE EN COURS POUR DÉPÔT " 
                   WS-DEPOT-RECH
           DISPLAY "PRODUIT    | STOCK THÉORIQUE | STOCK PHYSIQUE | ÉCART"
           DISPLAY "-----------+-----------------+----------------+--------"
           
           MOVE WS-DEPOT-RECH TO WS-DEPOT-CODE
           MOVE SPACES TO WS-PROD-CODE
           START FICHIER-STOCKS 
               KEY IS NOT < WS-DEPOT-CODE
           
           PERFORM UNTIL WS-FS-STK = '10'
               READ FICHIER-STOCKS NEXT
                   AT END
                       MOVE '10' TO WS-FS-STK
                   NOT AT END
                       IF WS-DEPOT-CODE = WS-DEPOT-RECH
                           DISPLAY WS-PROD-CODE " | "
                                   WS-QUANTITE-STOCK " | "
                                   WITH NO ADVANCING
                           ACCEPT WS-STOCK-PHYSIQUE
                           COMPUTE WS-ECART = 
                               WS-QUANTITE-STOCK - 
                               WS-STOCK-PHYSIQUE
                           DISPLAY " | " WS-ECART
                           
                           IF WS-ECART NOT = 0
                               MOVE WS-STOCK-PHYSIQUE 
                                 TO WS-QUANTITE-STOCK
                               REWRITE WS-STOCK
                               DISPLAY "STOCK CORRIGÉ"
                           END-IF
                       END-IF
               END-READ
           END-PERFORM
           
           DISPLAY "INVENTAIRE TERMINÉ"
           .
       
       8200-RAPPORT-STOCK.
           DISPLAY "--- RAPPORT DE STOCK ---"
           DISPLAY "DÉPÔT: "
           ACCEPT WS-DEPOT-RECH
           
           MOVE WS-DEPOT-RECH TO WS-CODE-DEPOT
           READ FICHIER-DEPOTS
               INVALID KEY
                   DISPLAY "DÉPÔT NON TROUVÉ"
               NOT INVALID KEY
                   DISPLAY "========================================"
                   DISPLAY "RAPPORT DE STOCK - " 
                           FUNCTION TRIM(WS-NOM-DEPOT)
                   DISPLAY "DATE: " WS-DATE-COURANTE-INV
                   DISPLAY "========================================"
                   DISPLAY "PRODUIT | QTE | MIN | MAX | ÉTAT"
                   DISPLAY "--------+-----+-----+-----+--------"
                   
                   MOVE WS-DEPOT-RECH TO WS-DEPOT-CODE
                   MOVE SPACES TO WS-PROD-CODE
                   START FICHIER-STOCKS 
                       KEY IS NOT < WS-DEPOT-CODE
                   
                   PERFORM UNTIL WS-FS-STK = '10'
                       READ FICHIER-STOCKS NEXT
                           AT END
                               MOVE '10' TO WS-FS-STK
                           NOT AT END
                               IF WS-DEPOT-CODE = WS-DEPOT-RECH
                                   IF WS-QUANTITE-STOCK 
                                      <= WS-QUANTITE-MIN
                                       DISPLAY WS-PROD-CODE " | "
                                               WS-QUANTITE-STOCK " | "
                                               WS-QUANTITE-MIN " | "
                                               WS-QUANTITE-MAX " | "
                                               "ALERTE"
                                   ELSE
                                       IF WS-QUANTITE-STOCK 
                                          >= WS-QUANTITE-MAX
                                           DISPLAY WS-PROD-CODE " | "
                                                   WS-QUANTITE-STOCK 
                                                   " | "
                                                   WS-QUANTITE-MIN 
                                                   " | "
                                                   WS-QUANTITE-MAX 
                                                   " | SATURATION"
                                       ELSE
                                           DISPLAY WS-PROD-CODE " | "
                                                   WS-QUANTITE-STOCK 
                                                   " | "
                                                   WS-QUANTITE-MIN 
                                                   " | "
                                                   WS-QUANTITE-MAX 
                                                   " | OK"
                                       END-IF
                                   END-IF
                               END-IF
                       END-READ
                   END-PERFORM
           END-READ
           .
       
       8300-ALERTES-STOCK-MULTI.
           DISPLAY "=== ALERTES STOCK MULTI-DÉPÔTS ==="
           DISPLAY "PRODUITS EN ALERTE (STOCK < MINIMUM):"
           DISPLAY "DÉPÔT      | PRODUIT    | STOCK | MIN"
           DISPLAY "-----------+------------+-------+-----"
           
           MOVE SPACES TO WS-DEPOT-CODE
           START FICHIER-STOCKS 
               KEY IS NOT < WS-DEPOT-CODE
           
           PERFORM UNTIL WS-FS-STK = '10'
               READ FICHIER-STOCKS NEXT
                   AT END
                       MOVE '10' TO WS-FS-STK
                   NOT AT END
                       IF WS-QUANTITE-STOCK <= WS-QUANTITE-MIN
                           DISPLAY WS-DEPOT-CODE " | "
                                   WS-PROD-CODE " | "
                                   WS-QUANTITE-STOCK " | "
                                   WS-QUANTITE-MIN
                       END-IF
               END-READ
           END-PERFORM
           .
       
       8400-TABLEAU-BORD-STOCK.
           DISPLAY "=== TABLEAU DE BORD INVENTAIRE ==="
           DISPLAY "INDICATEURS GLOBAUX:"
           DISPLAY "---------------------"
           
           MOVE 0 TO WS-STOCK-TOTAL WS-ALERTES-TOTAL
           MOVE 0 TO WS-CAPACITE-TOTALE WS-CAPACITE-OCCUPEE
           
           MOVE SPACES TO WS-DEPOT-CODE
           START FICHIER-STOCKS 
               KEY IS NOT < WS-DEPOT-CODE
           
           PERFORM UNTIL WS-FS-STK = '10'
               READ FICHIER-STOCKS NEXT
                   AT END
                       MOVE '10' TO WS-FS-STK
                   NOT AT END
                       ADD WS-QUANTITE-STOCK TO WS-STOCK-TOTAL
                       IF WS-QUANTITE-STOCK <= WS-QUANTITE-MIN
                           ADD 1 TO WS-ALERTES-TOTAL
                       END-IF
               END-READ
           END-PERFORM
           
           MOVE SPACES TO WS-CODE-DEPOT
           START FICHIER-DEPOTS KEY IS NOT < WS-CODE-DEPOT
           
           PERFORM UNTIL WS-FS-DEP = '10'
               READ FICHIER-DEPOTS NEXT
                   AT END
                       MOVE '10' TO WS-FS-DEP
                   NOT AT END
                       ADD WS-CAPACITE-MAX TO WS-CAPACITE-TOTALE
                       ADD WS-CAPACITE-USEE 
                         TO WS-CAPACITE-OCCUPEE
               END-READ
           END-PERFORM
           
           COMPUTE WS-TAUX-OCC-GLOBAL = 
               (WS-CAPACITE-OCCUPEE * 100) / 
               WS-CAPACITE-TOTALE
           
           DISPLAY "STOCK TOTAL TOUS DÉPÔTS: " WS-STOCK-TOTAL
           DISPLAY "NOMBRE D'ALERTES STOCK: " WS-ALERTES-TOTAL
           DISPLAY "CAPACITÉ TOTALE: " 
                   WS-CAPACITE-OCCUPEE "/" 
                   WS-CAPACITE-TOTALE
           DISPLAY "TAUX OCCUPATION MOYEN: " 
                   WS-TAUX-OCC-GLOBAL "%"
           .
       
       9000-FERMER-INVENTORY.
           CLOSE FICHIER-DEPOTS
           CLOSE FICHIER-STOCKS
           CLOSE FICHIER-TRANSFERTS
           DISPLAY "SYSTÈME D'INVENTAIRE ARRÊTÉ"
           .
