       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-TRAJETS.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMMANDE      PIC X(200).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "========================================="
           DISPLAY "         LISTE DES TRAJETS"
           DISPLAY "========================================="
           
           MOVE "sqlite3 data/transport.db 'SELECT ID_TRAJET FROM TRAJETS;'"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           
           MOVE "sqlite3 data/transport.db 'SELECT VILLE_DEPART FROM TRAJETS;'"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           
           MOVE "sqlite3 data/transport.db 'SELECT VILLE_ARRIVEE FROM TRAJETS;'"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           
           MOVE "sqlite3 data/transport.db 'SELECT DATE_DEPART FROM TRAJETS;'"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           
           MOVE "sqlite3 data/transport.db 'SELECT PRIX_PLACE FROM TRAJETS;'"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY "========================================="
           STOP RUN.
