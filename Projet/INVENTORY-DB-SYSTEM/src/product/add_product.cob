       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADD-PRODUCT.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-CODE       PIC X(20).
       01 WS-NOM        PIC X(100).
       01 WS-DESC       PIC X(255).
       01 WS-PRIX-ACHAT PIC 9(10)V99.
       01 WS-PRIX-VENTE PIC 9(10)V99.
       01 WS-STOCK      PIC 9(10).
       01 WS-STOCK-MIN  PIC 9(10).
       01 WS-ID-CAT     PIC 9(5).
       01 WS-ID-FOURN   PIC 9(5).
       01 WS-CMD        PIC X(500).

       PROCEDURE DIVISION.
       MAIN.
           DISPLAY "=== AJOUTER UN PRODUIT ==="
           DISPLAY "Code produit : " WITH NO ADVANCING
           ACCEPT WS-CODE
           DISPLAY "Nom : " WITH NO ADVANCING
           ACCEPT WS-NOM
           DISPLAY "Description : " WITH NO ADVANCING
           ACCEPT WS-DESC
           DISPLAY "Prix d'achat : " WITH NO ADVANCING
           ACCEPT WS-PRIX-ACHAT
           DISPLAY "Prix de vente : " WITH NO ADVANCING
           ACCEPT WS-PRIX-VENTE
           DISPLAY "Stock initial : " WITH NO ADVANCING
           ACCEPT WS-STOCK
           DISPLAY "Stock minimum : " WITH NO ADVANCING
           ACCEPT WS-STOCK-MIN
           DISPLAY "ID Catégorie : " WITH NO ADVANCING
           ACCEPT WS-ID-CAT
           DISPLAY "ID Fournisseur principal : " WITH NO ADVANCING
           ACCEPT WS-ID-FOURN

           STRING
               "sqlite3 data/inventory.db ""INSERT INTO produits "
               "(code_produit, nom_produit, description, prix_achat, prix_vente, "
               "stock_actuel, stock_min, id_categorie, id_fournisseur_principal) VALUES ('"
               FUNCTION TRIM(WS-CODE) "', '"
               FUNCTION TRIM(WS-NOM) "', '"
               FUNCTION TRIM(WS-DESC) "', "
               WS-PRIX-ACHAT ", " WS-PRIX-VENTE ", "
               WS-STOCK ", " WS-STOCK-MIN ", "
               WS-ID-CAT ", " WS-ID-FOURN ");"""
               INTO WS-CMD
           END-STRING
           CALL "SYSTEM" USING WS-CMD
           DISPLAY "Produit ajouté."
           STOP RUN.