       IDENTIFICATION DIVISION.
       PROGRAM-ID. RECHERCHER-CLIENT.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID         PIC X(6).
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║              RECHERCHER UN CLIENT                  ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "ID Client : " WITH NO ADVANCING
           ACCEPT WS-ID
           
           STRING "sqlite3 data/input/hotel.db 'SELECT "
               "'ID: ' || ID_CLIENT || CHAR(10) || "
               "'NOM: ' || NOM || CHAR(10) || "
               "'PRENOM: ' || PRENOM || CHAR(10) || "
               "'EMAIL: ' || EMAIL || CHAR(10) || "
               "'TEL: ' || TELEPHONE || CHAR(10) || "
               "'ADRESSE: ' || ADRESSE || CHAR(10) || "
               "'STATUT: ' || STATUT "
               "FROM CLIENTS WHERE ID_CLIENT = '\''" 
               FUNCTION TRIM(WS-ID) "'\'';'"
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
