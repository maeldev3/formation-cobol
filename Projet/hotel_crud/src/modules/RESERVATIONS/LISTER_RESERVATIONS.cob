       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-RESERVATIONS.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════════════════════╗"
           DISPLAY "║                    LISTE DES RESERVATIONS                          ║"
           DISPLAY "╠════════════════════════════════════════════════════════════════════╣"
           DISPLAY "║ ID         CLIENT   CHAMBRE  DEBUT       FIN         STATUT        ║"
           DISPLAY "╠════════════════════════════════════════════════════════════════════╣"
           
           STRING "sqlite3 data/input/hotel.db 'SELECT "
               "ID_RESERVATION || \" | \" || ID_CLIENT || \" | \" || "
               "ID_CHAMBRE || \" | \" || DATE_DEBUT || \" | \" || DATE_FIN || "
               "\" | \" || STATUT FROM RESERVATIONS ORDER BY DATE_DEBUT;'"
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           DISPLAY "╚════════════════════════════════════════════════════════════════════╝"
           STOP RUN.
