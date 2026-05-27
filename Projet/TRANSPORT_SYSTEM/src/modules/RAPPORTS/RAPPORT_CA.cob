       IDENTIFICATION DIVISION.
       PROGRAM-ID. RAPPORT-CA.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMMANDE      PIC X(200).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "========================================="
           DISPLAY "   RAPPORT CHIFFRE D'AFFAIRES"
           DISPLAY "========================================="
           
           MOVE "sqlite3 data/transport.db 'SELECT SUM(PRIX_PLACE * 50) FROM TRAJETS;'"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY "========================================="
           STOP RUN.
