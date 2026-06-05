       IDENTIFICATION DIVISION.
       PROGRAM-ID. LIST-PRODUCTS.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-CMD        PIC X(500).

       PROCEDURE DIVISION.
       MAIN.
           DISPLAY "=== LISTE DES PRODUITS ==="
           STRING "sqlite3 data/inventory.db 'SELECT id_produit, code_produit, nom_produit, stock_actuel FROM produits;'"
               INTO WS-CMD
           END-STRING
           CALL "SYSTEM" USING WS-CMD
           STOP RUN.