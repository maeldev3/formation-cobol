       IDENTIFICATION DIVISION.
       PROGRAM-ID. CREER-TRAJET.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID           PIC X(10).
       01 WS-BUS          PIC X(10).
       01 WS-CONDUCTEUR   PIC X(10).
       01 WS-DEPART       PIC X(30).
       01 WS-ARRIVEE      PIC X(30).
       01 WS-DATE         PIC X(10).
       01 WS-HEURE        PIC X(5).
       01 WS-PRIX         PIC 9(5)V99.
       01 WS-COMMANDE     PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "CREATION D'UN TRAJET"
           DISPLAY "===================="
           DISPLAY " "
           DISPLAY "ID (TRJ001) : " WITH NO ADVANCING
           ACCEPT WS-ID
           DISPLAY "ID BUS : " WITH NO ADVANCING
           ACCEPT WS-BUS
           DISPLAY "ID CONDUCTEUR : " WITH NO ADVANCING
           ACCEPT WS-CONDUCTEUR
           DISPLAY "Ville depart : " WITH NO ADVANCING
           ACCEPT WS-DEPART
           DISPLAY "Ville arrivee : " WITH NO ADVANCING
           ACCEPT WS-ARRIVEE
           DISPLAY "Date (YYYY-MM-DD) : " WITH NO ADVANCING
           ACCEPT WS-DATE
           DISPLAY "Heure (HH:MM) : " WITH NO ADVANCING
           ACCEPT WS-HEURE
           DISPLAY "Prix place : " WITH NO ADVANCING
           ACCEPT WS-PRIX
           
           STRING 
               "sqlite3 data/transport.db "
               "'INSERT INTO TRAJETS VALUES ("
               "'" FUNCTION TRIM(WS-ID) "',"
               "'" FUNCTION TRIM(WS-BUS) "',"
               "'" FUNCTION TRIM(WS-CONDUCTEUR) "',"
               "'" FUNCTION TRIM(WS-DEPART) "',"
               "'" FUNCTION TRIM(WS-ARRIVEE) "',"
               "'" FUNCTION TRIM(WS-DATE) "',"
               "'" FUNCTION TRIM(WS-HEURE) "',"
               "'" FUNCTION TRIM(WS-DATE) "',"
               "'" FUNCTION TRIM(WS-HEURE) "',"
               "0," WS-PRIX ",50,'PROGRAMME')'"
               INTO WS-COMMANDE
           END-STRING
           
           CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY " "
           DISPLAY "TRAJET CREE AVEC SUCCES !"
           DISPLAY "ID: " WS-ID
           STOP RUN.
