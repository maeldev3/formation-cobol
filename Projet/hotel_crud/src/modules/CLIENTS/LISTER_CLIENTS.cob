       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-CLIENTS.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMMANDE     PIC X(500).
       
       PROCEDURE DIVISION.
           DISPLAY " "
           DISPLAY "=== LISTE DES CLIENTS ==="
           MOVE "sqlite3 data/input/hotel.db 'SELECT ID_CLIENT || \" | \" || "
               "NOM || \" \" || PRENOM || \" | \" || TELEPHONE FROM CLIENTS;'"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           STOP RUN.