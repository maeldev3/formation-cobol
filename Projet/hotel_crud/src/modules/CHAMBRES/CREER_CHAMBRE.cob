       IDENTIFICATION DIVISION.
       PROGRAM-ID. CREER-CHAMBRE.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID         PIC X(6).
       01 WS-NUMERO     PIC X(5).
       01 WS-TYPE       PIC X(6).
       01 WS-ETAGE      PIC 99.
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║              CREER UNE CHAMBRE                     ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY " "
           DISPLAY "ID Chambre (CH001) : " WITH NO ADVANCING
           ACCEPT WS-ID
           DISPLAY "Numero : " WITH NO ADVANCING
           ACCEPT WS-NUMERO
           DISPLAY "Type (TYP001-TYP005) : " WITH NO ADVANCING
           ACCEPT WS-TYPE
           DISPLAY "Etage : " WITH NO ADVANCING
           ACCEPT WS-ETAGE
           
           STRING "sqlite3 data/input/hotel.db \"INSERT INTO CHAMBRES VALUES ('"
               FUNCTION TRIM(WS-ID) "', '"
               FUNCTION TRIM(WS-NUMERO) "', '"
               FUNCTION TRIM(WS-TYPE) "', " WS-ETAGE
               ", 'DISPONIBLE', date('now'), NULL);\""
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY " "
           DISPLAY "✓ CHAMBRE CREEE AVEC SUCCES !"
           DISPLAY "  ID: " WS-ID " - Numero: " FUNCTION TRIM(WS-NUMERO)
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
