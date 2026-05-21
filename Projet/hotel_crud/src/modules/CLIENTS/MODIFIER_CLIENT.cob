       IDENTIFICATION DIVISION.
       PROGRAM-ID. MODIFIER-CLIENT.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID         PIC X(6).
       01 WS-TEL        PIC X(12).
       01 WS-ADRESSE    PIC X(40).
       01 WS-STATUT     PIC X(10).
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║              MODIFIER UN CLIENT                    ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "ID Client : " WITH NO ADVANCING
           ACCEPT WS-ID
           DISPLAY "NOUVEAU TELEPHONE : " WITH NO ADVANCING
           ACCEPT WS-TEL
           DISPLAY "NOUVELLE ADRESSE : " WITH NO ADVANCING
           ACCEPT WS-ADRESSE
           DISPLAY "NOUVEAU STATUT (ACTIF/INACTIF) : " WITH NO ADVANCING
           ACCEPT WS-STATUT
           
           STRING "sqlite3 data/input/hotel.db \"UPDATE CLIENTS SET "
               "TELEPHONE = '" FUNCTION TRIM(WS-TEL) "', "
               "ADRESSE = '" FUNCTION TRIM(WS-ADRESSE) "', "
               "STATUT = '" FUNCTION TRIM(WS-STATUT) "' "
               "WHERE ID_CLIENT = '" FUNCTION TRIM(WS-ID) "';\""
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY " "
           DISPLAY "✓ CLIENT MODIFIE AVEC SUCCES !"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
