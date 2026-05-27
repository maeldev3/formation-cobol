       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-BUS.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMMANDE      PIC X(200).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "========================================="
           DISPLAY "         LISTE DES BUS"
           DISPLAY "========================================="
           
           MOVE "sqlite3 data/transport.db 'SELECT ID_BUS FROM BUS;'"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           
           MOVE "sqlite3 data/transport.db 'SELECT MARQUE FROM BUS;'"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           
           MOVE "sqlite3 data/transport.db 'SELECT MODELE FROM BUS;'"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           
           MOVE "sqlite3 data/transport.db 'SELECT CAPACITE FROM BUS;'"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY "========================================="
           STOP RUN.
