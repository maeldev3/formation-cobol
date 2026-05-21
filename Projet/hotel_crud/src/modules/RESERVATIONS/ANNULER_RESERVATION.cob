       IDENTIFICATION DIVISION.
       PROGRAM-ID. ANNULER-RESERVATION.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID         PIC X(8).
       01 WS-CONFIRM    PIC X.
       01 WS-COMMANDE   PIC X(500).
       01 WS-CHAMBRE    PIC X(6).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║           ANNULER UNE RESERVATION                  ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "ID Reservation : " WITH NO ADVANCING
           ACCEPT WS-ID
           DISPLAY "Confirmer annulation (O/N) : " WITH NO ADVANCING
           ACCEPT WS-CONFIRM
           
           IF WS-CONFIRM = 'O' OR 'o'
               STRING "sqlite3 data/input/hotel.db \"UPDATE RESERVATIONS SET STATUT = 'ANNULEE' "
                   "WHERE ID_RESERVATION = '" FUNCTION TRIM(WS-ID) "';\""
                   INTO WS-COMMANDE
               END-STRING
               CALL "SYSTEM" USING WS-COMMANDE
               
               STRING "sqlite3 data/input/hotel.db \"UPDATE CHAMBRES SET STATUT = 'DISPONIBLE' "
                   "WHERE ID_CHAMBRE = (SELECT ID_CHAMBRE FROM RESERVATIONS "
                   "WHERE ID_RESERVATION = '" FUNCTION TRIM(WS-ID) "');\""
                   INTO WS-COMMANDE
               END-STRING
               CALL "SYSTEM" USING WS-COMMANDE
               
               DISPLAY " "
               DISPLAY "✓ RESERVATION ANNULEE"
           ELSE
               DISPLAY "Annulation annulee"
           END-IF
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
