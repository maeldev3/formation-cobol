       IDENTIFICATION DIVISION.
       PROGRAM-ID. CREER-CONDUCTEUR.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID           PIC X(10).
       01 WS-NOM          PIC X(30).
       01 WS-PRENOM       PIC X(30).
       01 WS-EMAIL        PIC X(50).
       01 WS-TEL          PIC X(15).
       01 WS-PERMIS       PIC X(15).
       01 WS-COMMANDE     PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "CREATION D'UN CONDUCTEUR"
           DISPLAY "========================"
           DISPLAY " "
           DISPLAY "ID (DRV001) : " WITH NO ADVANCING
           ACCEPT WS-ID
           DISPLAY "NOM : " WITH NO ADVANCING
           ACCEPT WS-NOM
           DISPLAY "PRENOM : " WITH NO ADVANCING
           ACCEPT WS-PRENOM
           DISPLAY "EMAIL : " WITH NO ADVANCING
           ACCEPT WS-EMAIL
           DISPLAY "TELEPHONE : " WITH NO ADVANCING
           ACCEPT WS-TEL
           DISPLAY "NUMERO PERMIS : " WITH NO ADVANCING
           ACCEPT WS-PERMIS
           
           STRING 
               "sqlite3 data/transport.db "
               "'INSERT INTO CONDUCTEURS VALUES ("
               "'" FUNCTION TRIM(WS-ID) "',"
               "'" FUNCTION TRIM(WS-NOM) "',"
               "'" FUNCTION TRIM(WS-PRENOM) "',"
               "'" FUNCTION TRIM(WS-EMAIL) "',"
               "'" FUNCTION TRIM(WS-TEL) "',"
               "'','','','" FUNCTION TRIM(WS-PERMIS) "',"
               "date('now'),'ACTIF',2000)'"
               INTO WS-COMMANDE
           END-STRING
           
           CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY " "
           DISPLAY "CONDUCTEUR CREE AVEC SUCCES !"
           DISPLAY "ID: " WS-ID
           STOP RUN.
