       IDENTIFICATION DIVISION.
       PROGRAM-ID. CREER-RESERVATION.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID         PIC X(20).
       01 WS-CLIENT     PIC X(6).
       01 WS-CHAMBRE    PIC X(6).
       01 WS-DEBUT      PIC X(10).
       01 WS-FIN        PIC X(10).
       01 WS-PERSONNES  PIC 99.
       01 WS-PRIX       PIC 9(5)V99.
       01 WS-MONTANT    PIC 9(6)V99.
       01 WS-COMMANDE   PIC X(1024).
       01 WS-SQL-FICHIER PIC X(50) VALUE "temp.sql".
       
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
           DISPLAY "Prix par nuit (€) : " WITH NO ADVANCING
           ACCEPT WS-PRIX
           
           MOVE 1 TO WS-MONTANT
           COMPUTE WS-MONTANT = WS-PRIX * 1
           
      *> Générer ID
           STRING "RES" 
               FUNCTION CURRENT-DATE(1:4)
               FUNCTION CURRENT-DATE(6:2)
               FUNCTION CURRENT-DATE(9:2)
               FUNCTION CURRENT-DATE(12:2)
               FUNCTION CURRENT-DATE(15:2)
               INTO WS-ID
           END-STRING
           
      *> Créer un fichier SQL temporaire
           STRING 
               "INSERT INTO RESERVATIONS (ID_RESERVATION, ID_CLIENT, "
               "ID_CHAMBRE, DATE_DEBUT, DATE_FIN, NB_PERSONNES, STATUT, "
               "DATE_RESERVATION, MONTANT_TOTAL, REMARQUES) VALUES ("
               "'" FUNCTION TRIM(WS-ID) "', "
               "'" FUNCTION TRIM(WS-CLIENT) "', "
               "'" FUNCTION TRIM(WS-CHAMBRE) "', "
               "'" FUNCTION TRIM(WS-DEBUT) "', "
               "'" FUNCTION TRIM(WS-FIN) "', "
               FUNCTION NUMVAL(WS-PERSONNES) ", "
               "'CONFIRMEE', date('now'), "
               WS-MONTANT ", NULL);"
               INTO WS-COMMANDE
           END-STRING
           
      *> Écrire dans un fichier
           CALL "SYSTEM" 
               USING "echo " FUNCTION TRIM(WS-COMMANDE) 
               " > " WS-SQL-FICHIER
           
      *> Exécuter le fichier SQL
           CALL "SYSTEM" 
               USING "sqlite3 data/input/hotel.db < " WS-SQL-FICHIER
           
      *> Nettoyer
           CALL "SYSTEM" USING "rm " WS-SQL-FICHIER
           
           DISPLAY " "
           DISPLAY "✓ RESERVATION CREEE AVEC SUCCES !"
           DISPLAY "  ID: " WS-ID
           DISPLAY "  Montant: " WS-MONTANT " €"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.