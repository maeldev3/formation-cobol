       IDENTIFICATION DIVISION.
       PROGRAM-ID. DB-TEST.

       ENVIRONMENT DIVISION.

       DATA DIVISION.

       WORKING-STORAGE SECTION.
       01 WS-CMD PIC X(200).

       PROCEDURE DIVISION.

           DISPLAY "===================="
           DISPLAY " TEST SQLITE DB "
           DISPLAY "===================="

      *    Vérifier la présence des tables
           MOVE "sqlite3 data/inventory.db '.tables'" TO WS-CMD
           CALL "SYSTEM" USING WS-CMD

           DISPLAY " "
           DISPLAY "---- Comptage des produits ----"
           MOVE "sqlite3 data/inventory.db 'SELECT COUNT(*) FROM produits;'" 
             TO WS-CMD
           CALL "SYSTEM" USING WS-CMD

           DISPLAY " "
           DISPLAY "DONE"

           STOP RUN.