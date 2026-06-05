       IDENTIFICATION DIVISION.
       PROGRAM-ID. UPDATE-STOCK.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID-PROD    PIC 9(10).
       01 WS-NOUVEAU-STOCK PIC 9(10).
       01 WS-CMD        PIC X(500).

       PROCEDURE DIVISION.
       MAIN.
           DISPLAY "=== MISE À JOUR STOCK PRODUIT ==="
           DISPLAY "ID Produit : " WITH NO ADVANCING
           ACCEPT WS-ID-PROD
           DISPLAY "Nouveau stock : " WITH NO ADVANCING
           ACCEPT WS-NOUVEAU-STOCK

           STRING
               "sqlite3 data/inventory.db ""UPDATE produits SET stock_actuel = "
               WS-NOUVEAU-STOCK " WHERE id_produit = " WS-ID-PROD ";"""
               INTO WS-CMD
           END-STRING
           CALL "SYSTEM" USING WS-CMD
           DISPLAY "Stock mis à jour."
           STOP RUN.