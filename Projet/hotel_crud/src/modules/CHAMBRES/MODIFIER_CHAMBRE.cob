       IDENTIFICATION DIVISION.
       PROGRAM-ID. MODIFIER-CHAMBRE.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID         PIC X(6).
       01 WS-STATUT     PIC X(15).
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║           MODIFIER STATUT CHAMBRE                  ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "ID Chambre : " WITH NO ADVANCING
           ACCEPT WS-ID
           DISPLAY "Nouveau statut (DISPONIBLE/OCCUPEE/RESERVEE) : " 
               WITH NO ADVANCING
           ACCEPT WS-STATUT
           
           STRING "sqlite3 data/input/hotel.db \"UPDATE CHAMBRES SET STATUT = '"
               FUNCTION TRIM(WS-STATUT) "' WHERE ID_CHAMBRE = '"
               FUNCTION TRIM(WS-ID) "';\""
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY " "
           DISPLAY "✓ STATUT MODIFIE AVEC SUCCES !"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
