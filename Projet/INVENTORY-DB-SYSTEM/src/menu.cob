       IDENTIFICATION DIVISION.
       PROGRAM-ID. MENU.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-CHOICE PIC 99.
       01 WS-LOGIN-STATUS PIC X.
           88 USER-LOGGED-IN VALUE 'Y'.

       PROCEDURE DIVISION.
       MAIN.
      *> Appel du login
           CALL "LOGIN" USING WS-LOGIN-STATUS
           IF NOT USER-LOGGED-IN
               DISPLAY "Authentification échouée. Au revoir."
               STOP RUN
           END-IF.

           PERFORM UNTIL WS-CHOICE = 0
               DISPLAY " "
               DISPLAY "╔════════════════════════════════════════╗"
               DISPLAY "║       GESTION D'INVENTAIRE             ║"
               DISPLAY "╠════════════════════════════════════════╣"
               DISPLAY "║  1. Catégories                         ║"
               DISPLAY "║  2. Produits                           ║"
               DISPLAY "║  3. Mouvements de stock                ║"
               DISPLAY "║  4. Utilisateurs (réservé admin)       ║"
               DISPLAY "║  0. Quitter                            ║"
               DISPLAY "╚════════════════════════════════════════╝"
               DISPLAY "Votre choix : " WITH NO ADVANCING
               ACCEPT WS-CHOICE

               EVALUATE WS-CHOICE
                   WHEN 1
                       PERFORM MENU-CATEGORIES
                   WHEN 2
                       PERFORM MENU-PRODUITS
                   WHEN 3
                       PERFORM MENU-STOCK
                   WHEN 4
                       PERFORM MENU-UTILISATEURS
                   WHEN 0
                       DISPLAY "Au revoir"
                   WHEN OTHER
                       DISPLAY "Choix invalide"
               END-EVALUATE
           END-PERFORM
           STOP RUN.

       MENU-CATEGORIES.
           DISPLAY " "
           DISPLAY "--- Gestion des catégories ---"
           DISPLAY "1. Ajouter une catégorie"
           DISPLAY "2. Lister les catégories"
           DISPLAY "0. Retour"
           ACCEPT WS-CHOICE
           EVALUATE WS-CHOICE
               WHEN 1
                   CALL "CREATE-CATEGORY"
               WHEN 2
                   CALL "LIST-CATEGORIES"
               WHEN OTHER
                   CONTINUE
           END-EVALUATE.

       MENU-PRODUITS.
           DISPLAY " "
           DISPLAY "--- Gestion des produits ---"
           DISPLAY "1. Ajouter un produit"
           DISPLAY "2. Lister les produits"
           DISPLAY "3. Mettre à jour le stock"
           DISPLAY "0. Retour"
           ACCEPT WS-CHOICE
           EVALUATE WS-CHOICE
               WHEN 1
                   CALL "ADD-PRODUCT"
               WHEN 2
                   CALL "LIST-PRODUCTS"
               WHEN 3
                   CALL "UPDATE-STOCK"
               WHEN OTHER
                   CONTINUE
           END-EVALUATE.

       MENU-STOCK.
           DISPLAY " "
           DISPLAY "--- Mouvements de stock ---"
           DISPLAY "1. Ajouter un mouvement (entrée/sortie)"
           DISPLAY "0. Retour"
           ACCEPT WS-CHOICE
           IF WS-CHOICE = 1
               CALL "ADD-MOVEMENT"
           END-IF.

       MENU-UTILISATEURS.
           DISPLAY "Fonctionnalité réservée à l'admin (à implémenter)"
      *>    Ici vous pourrez appeler un programme "MANAGE-USERS"
           .