       IDENTIFICATION DIVISION.
       PROGRAM-ID. RAPPORT-OCCUPATION.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMMANDE      PIC X(200).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "========================================="
           DISPLAY "     RAPPORT OCCUPATION DES BUS"
           DISPLAY "========================================="
           
           MOVE "sqlite3 data/transport.db 'SELECT ID_BUS FROM BUS WHERE STATUT != 'DISPONIBLE';'"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           
           MOVE "sqlite3 data/transport.db 'SELECT MARQUE FROM BUS WHERE STATUT != 'DISPONIBLE';'"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY "========================================="
           STOP RUN.
