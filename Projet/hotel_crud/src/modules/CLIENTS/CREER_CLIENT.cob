       IDENTIFICATION DIVISION.
       PROGRAM-ID. CREER-CLIENT.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID         PIC X(6).
       01 WS-NOM        PIC X(20).
       01 WS-PRENOM     PIC X(15).
       01 WS-EMAIL      PIC X(30).
       01 WS-TEL        PIC X(12).
       01 WS-ADRESSE    PIC X(40).
       01 WS-VILLE      PIC X(20).
       01 WS-CP         PIC X(5).
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║              CREER UN NOUVEAU CLIENT               ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY " "
           DISPLAY "ID Client (C00001) : " WITH NO ADVANCING
           ACCEPT WS-ID
           DISPLAY "NOM : " WITH NO ADVANCING
           ACCEPT WS-NOM
           DISPLAY "PRENOM : " WITH NO ADVANCING
           ACCEPT WS-PRENOM
           DISPLAY "EMAIL : " WITH NO ADVANCING
           ACCEPT WS-EMAIL
           DISPLAY "TELEPHONE : " WITH NO ADVANCING
           ACCEPT WS-TEL
           DISPLAY "ADRESSE : " WITH NO ADVANCING
           ACCEPT WS-ADRESSE
           DISPLAY "VILLE : " WITH NO ADVANCING
           ACCEPT WS-VILLE
           DISPLAY "CODE POSTAL : " WITH NO ADVANCING
           ACCEPT WS-CP
           
           STRING "sqlite3 data/input/hotel.db \"INSERT INTO CLIENTS VALUES ('"
               FUNCTION TRIM(WS-ID) "', '"
               FUNCTION TRIM(WS-NOM) "', '"
               FUNCTION TRIM(WS-PRENOM) "', '"
               FUNCTION TRIM(WS-EMAIL) "', '"
               FUNCTION TRIM(WS-TEL) "', '"
               FUNCTION TRIM(WS-ADRESSE) "', '"
               FUNCTION TRIM(WS-VILLE) "', '"
               FUNCTION TRIM(WS-CP) "', date('now'), 'ACTIF');\""
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY " "
           DISPLAY "✓ CLIENT CREE AVEC SUCCES !"
           DISPLAY "  ID: " WS-ID
           DISPLAY "  Nom: " FUNCTION TRIM(WS-NOM) " " FUNCTION TRIM(WS-PRENOM)
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
