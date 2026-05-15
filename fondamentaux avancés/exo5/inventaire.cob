       IDENTIFICATION DIVISION.
       PROGRAM-ID. INVENTAIRE.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-PRODUITS
               ASSIGN TO "produits.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-CODE-PRODUIT
               FILE STATUS IS WS-FS.

       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-PRODUITS.
       01 WS-PRODUIT.
           05 WS-CODE-PRODUIT  PIC X(6).
           05 WS-NOM-PRODUIT   PIC X(30).
           05 WS-QUANTITE      PIC 9(5).
           05 WS-PRIX-UNITE    PIC 9(5)V99.
           05 WS-EMPLACEMENT   PIC X(5).

       WORKING-STORAGE SECTION.

       01 WS-CHOIX           PIC 9.
       01 WS-FIN             PIC X VALUE 'N'.

       01 WS-RECHERCHE       PIC X(6).
       01 WS-FS              PIC XX VALUE "00".
       01 WS-FOUND           PIC X VALUE 'N'.

       01 WS-VALEUR-TOTALE   PIC 9(9)V99 VALUE 0.

       01 WS-CONFIRMATION    PIC X VALUE 'N'.

       01 WS-LIST-END        PIC X VALUE 'N'.

       PROCEDURE DIVISION.

           PERFORM 1000-INIT
           PERFORM 2000-OUVRIR-FICHIER

           PERFORM UNTIL WS-FIN = 'O'
               PERFORM 3000-MENU
               PERFORM 4000-TRAITER
           END-PERFORM

           PERFORM 9000-FERMER
           STOP RUN.

       1000-INIT.
           DISPLAY "=== GESTION INVENTAIRE ==="
           .

       2000-OUVRIR-FICHIER.
           OPEN I-O FICHIER-PRODUITS

           IF WS-FS NOT = "00"
               OPEN OUTPUT FICHIER-PRODUITS
               CLOSE FICHIER-PRODUITS
               OPEN I-O FICHIER-PRODUITS
           END-IF
           .

       3000-MENU.
           DISPLAY " "
           DISPLAY "1. Ajouter"
           DISPLAY "2. Modifier"
           DISPLAY "3. Supprimer"
           DISPLAY "4. Rechercher"
           DISPLAY "5. Lister"
           DISPLAY "6. Valeur totale"
           DISPLAY "7. Quitter"
           DISPLAY "Choix: "
           ACCEPT WS-CHOIX
           .

       4000-TRAITER.
           EVALUATE WS-CHOIX
               WHEN 1 PERFORM 4100-AJOUTER
               WHEN 2 PERFORM 4200-MODIFIER
               WHEN 3 PERFORM 4300-SUPPRIMER
               WHEN 4 PERFORM 4400-RECHERCHER
               WHEN 5 PERFORM 4500-LISTER
               WHEN 6 PERFORM 4700-VALEUR
               WHEN 7 MOVE 'O' TO WS-FIN
               WHEN OTHER DISPLAY "Option invalide"
           END-EVALUATE
           .

       4100-AJOUTER.
           DISPLAY "Code produit: "
           ACCEPT WS-CODE-PRODUIT

           READ FICHIER-PRODUITS
               INVALID KEY
                   DISPLAY "Nom: "
                   ACCEPT WS-NOM-PRODUIT
                   DISPLAY "Quantite: "
                   ACCEPT WS-QUANTITE
                   DISPLAY "Prix: "
                   ACCEPT WS-PRIX-UNITE
                   DISPLAY "Emplacement: "
                   ACCEPT WS-EMPLACEMENT

                   WRITE WS-PRODUIT
                   DISPLAY "Ajout OK"
               NOT INVALID KEY
                   DISPLAY "Produit existe deja"
           END-READ
           .

       4200-MODIFIER.
           PERFORM 4400-RECHERCHER

           IF WS-FOUND = 'O'
               DISPLAY "Nom: "
               ACCEPT WS-NOM-PRODUIT
               DISPLAY "Quantite: "
               ACCEPT WS-QUANTITE
               DISPLAY "Prix: "
               ACCEPT WS-PRIX-UNITE
               DISPLAY "Emplacement: "
               ACCEPT WS-EMPLACEMENT

               REWRITE WS-PRODUIT
               DISPLAY "Modifie"
           END-IF
           .

       4300-SUPPRIMER.
           PERFORM 4400-RECHERCHER

           IF WS-FOUND = 'O'
               DISPLAY "Confirmer suppression (O/N): "
               ACCEPT WS-CONFIRMATION

               IF WS-CONFIRMATION = 'O'
                   DELETE FICHIER-PRODUITS
                   DISPLAY "Supprime"
               END-IF
           END-IF
           .

       4400-RECHERCHER.
           DISPLAY "Code: "
           ACCEPT WS-RECHERCHE

           MOVE WS-RECHERCHE TO WS-CODE-PRODUIT

           READ FICHIER-PRODUITS
               INVALID KEY
                   DISPLAY "Introuvable"
                   MOVE 'N' TO WS-FOUND
               NOT INVALID KEY
                   DISPLAY "Trouve: " WS-NOM-PRODUIT
                   MOVE 'O' TO WS-FOUND
           END-READ
           .

       4500-LISTER.
           DISPLAY "--- LISTE ---"

           MOVE SPACES TO WS-CODE-PRODUIT
           START FICHIER-PRODUITS KEY IS NOT < WS-CODE-PRODUIT

           MOVE 'N' TO WS-LIST-END

           PERFORM UNTIL WS-LIST-END = 'O'
               READ FICHIER-PRODUITS NEXT
                   AT END
                       MOVE 'O' TO WS-LIST-END
                   NOT AT END
                       DISPLAY WS-CODE-PRODUIT " | "
                               WS-NOM-PRODUIT " | "
                               WS-QUANTITE " | "
                               WS-PRIX-UNITE
               END-READ
           END-PERFORM
           .

       4700-VALEUR.
           MOVE 0 TO WS-VALEUR-TOTALE

           MOVE SPACES TO WS-CODE-PRODUIT
           START FICHIER-PRODUITS KEY IS NOT < WS-CODE-PRODUIT

           MOVE 'N' TO WS-LIST-END

           PERFORM UNTIL WS-LIST-END = 'O'
               READ FICHIER-PRODUITS NEXT
                   AT END
                       MOVE 'O' TO WS-LIST-END
                   NOT AT END
                       COMPUTE WS-VALEUR-TOTALE =
                           WS-VALEUR-TOTALE +
                           (WS-QUANTITE * WS-PRIX-UNITE)
               END-READ
           END-PERFORM

           DISPLAY "Valeur totale: " WS-VALEUR-TOTALE
           .

       9000-FERMER.
           CLOSE FICHIER-PRODUITS
           DISPLAY "Fermeture OK"
           .
