       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-CHAMBRES.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "========================================="
           DISPLAY "         LISTE DES CHAMBRES"
           DISPLAY "========================================="
           DISPLAY "ID      NUMERO   TYPE            PRIX    STATUT      ETAGE"
           DISPLAY "--------------------------------------------------------"
           
           STRING "sqlite3 data/input/hotel.db 'SELECT "
               "ID_CHAMBRE || \" | \" || NUMERO || \" | \" || "
               "TYPE || \" | \" || PRIX || \"€ | \" || "
               "STATUT || \" | \" || ETAGE "
               "FROM CHAMBRES ORDER BY NUMERO;'"
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           DISPLAY "========================================="
           STOP RUN.
