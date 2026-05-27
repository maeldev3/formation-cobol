       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-CONDUCTEURS.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMMANDE      PIC X(200).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "========================================="
           DISPLAY "       LISTE DES CONDUCTEURS"
           DISPLAY "========================================="
           
           MOVE "sqlite3 data/transport.db 'SELECT ID_CONDUCTEUR FROM CONDUCTEURS;'"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           
           MOVE "sqlite3 data/transport.db 'SELECT PRENOM FROM CONDUCTEURS;'"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           
           MOVE "sqlite3 data/transport.db 'SELECT NOM FROM CONDUCTEURS;'"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           
           MOVE "sqlite3 data/transport.db 'SELECT TELEPHONE FROM CONDUCTEURS;'"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY "========================================="
           STOP RUN.
