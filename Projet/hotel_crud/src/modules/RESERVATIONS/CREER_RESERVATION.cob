       IDENTIFICATION DIVISION.
       PROGRAM-ID. CREER-RESERVATION.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID         PIC X(8).
       01 WS-CLIENT     PIC X(6).
       01 WS-CHAMBRE    PIC X(6).
       01 WS-DEBUT      PIC X(10).
       01 WS-FIN        PIC X(10).
       01 WS-PERSONNES  PIC 99.
       01 WS-PRIX       PIC 9(5)V99.
       01 WS-NB-JOURS   PIC 9(3).
       01 WS-MONTANT    PIC 9(6)V99.
       01 WS-COMMANDE   PIC X(500).
       01 WS-PERSONNES-TXT PIC X(2).
       01 WS-MONTANT-TXT   PIC X(15).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║           CREER UNE RESERVATION                    ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY " "
           DISPLAY "ID Client : " WITH NO ADVANCING
           ACCEPT WS-CLIENT
           DISPLAY "ID Chambre : " WITH NO ADVANCING
           ACCEPT WS-CHAMBRE
           DISPLAY "Date debut (YYYY-MM-DD) : " WITH NO ADVANCING
           ACCEPT WS-DEBUT
           DISPLAY "Date fin (YYYY-MM-DD) : " WITH NO ADVANCING
           ACCEPT WS-FIN
           DISPLAY "Nombre de personnes : " WITH NO ADVANCING
           ACCEPT WS-PERSONNES
           
           STRING "RES" FUNCTION CURRENT-DATE(1:12)
               INTO WS-ID
           END-STRING
           
           STRING "sqlite3 data/input/hotel.db 'SELECT PRIX_BASE FROM TYPES_CHAMBRE "
               "WHERE ID_TYPE = (SELECT ID_TYPE FROM CHAMBRES WHERE ID_CHAMBRE = '\''"
               FUNCTION TRIM(WS-CHAMBRE) "'\'');'"
               INTO WS-COMMANDE
           END-STRING
           
           MOVE 80.00 TO WS-PRIX
           MOVE 3 TO WS-NB-JOURS
           COMPUTE WS-MONTANT = WS-PRIX * WS-NB-JOURS
           
           STRING "sqlite3 data/input/hotel.db \"INSERT INTO RESERVATIONS VALUES ('"
               FUNCTION TRIM(WS-ID) "', '"
               FUNCTION TRIM(WS-CLIENT) "', '"
               FUNCTION TRIM(WS-CHAMBRE) "', '"
               FUNCTION TRIM(WS-DEBUT) "', '"
               FUNCTION TRIM(WS-FIN) "', " WS-PERSONNES
               ", 'CONFIRMEE', date('now'), " WS-MONTANT ", NULL);\""
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           
           STRING "sqlite3 data/input/hotel.db \"UPDATE CHAMBRES SET STATUT = 'RESERVEE' "
               "WHERE ID_CHAMBRE = '" FUNCTION TRIM(WS-CHAMBRE) "';\""
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY " "
           DISPLAY "✓ RESERVATION CREEE AVEC SUCCES !"
           DISPLAY "  ID: " WS-ID
           DISPLAY "  Montant: " WS-MONTANT " €"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
