       IDENTIFICATION DIVISION.
       PROGRAM-ID. SUPPRIMER-CLIENT.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID         PIC X(6).
       01 WS-CONFIRM    PIC X.
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║              SUPPRIMER UN CLIENT                   ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "ID Client : " WITH NO ADVANCING
           ACCEPT WS-ID
           DISPLAY "Confirmer suppression (O/N) : " WITH NO ADVANCING
           ACCEPT WS-CONFIRM
           
           IF WS-CONFIRM = 'O' OR 'o'
               STRING "sqlite3 data/input/hotel.db \"DELETE FROM CLIENTS "
                   "WHERE ID_CLIENT = '" FUNCTION TRIM(WS-ID) "';\""
                   INTO WS-COMMANDE
               END-STRING
               CALL "SYSTEM" USING WS-COMMANDE
               DISPLAY " "
               DISPLAY "✓ CLIENT SUPPRIME AVEC SUCCES !"
           ELSE
               DISPLAY "Suppression annulee"
           END-IF
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
