       IDENTIFICATION DIVISION.
       PROGRAM-ID. CREER-BUS.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID-BUS        PIC X(10).
       01 WS-IMMAT         PIC X(15).
       01 WS-MARQUE        PIC X(30).
       01 WS-MODELE        PIC X(30).
       01 WS-CAPACITE      PIC 9(3).
       01 WS-ANNEE         PIC 9(4).
       01 WS-COMMANDE      PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "CREATION D'UN NOUVEAU BUS"
           DISPLAY "========================="
           DISPLAY " "
           DISPLAY "ID du bus (BUS001) : " WITH NO ADVANCING
           ACCEPT WS-ID-BUS
           DISPLAY "Immatriculation : " WITH NO ADVANCING
           ACCEPT WS-IMMAT
           DISPLAY "Marque : " WITH NO ADVANCING
           ACCEPT WS-MARQUE
           DISPLAY "Modele : " WITH NO ADVANCING
           ACCEPT WS-MODELE
           DISPLAY "Capacite : " WITH NO ADVANCING
           ACCEPT WS-CAPACITE
           DISPLAY "Annee : " WITH NO ADVANCING
           ACCEPT WS-ANNEE
           
           STRING 
               "sqlite3 data/transport.db " 
               "'INSERT INTO BUS VALUES ("
               "'" FUNCTION TRIM(WS-ID-BUS) "',"
               "'" FUNCTION TRIM(WS-IMMAT) "',"
               "'" FUNCTION TRIM(WS-MARQUE) "',"
               "'" FUNCTION TRIM(WS-MODELE) "',"
               WS-CAPACITE ","
               WS-ANNEE ",'DISPONIBLE',date('now'),'''')'"
               INTO WS-COMMANDE
           END-STRING
           
           CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY " "
           DISPLAY "BUS CREE AVEC SUCCES !"
           DISPLAY "ID: " WS-ID-BUS
           DISPLAY " "
           STOP RUN.
