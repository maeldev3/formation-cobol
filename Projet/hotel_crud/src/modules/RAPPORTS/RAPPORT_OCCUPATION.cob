       IDENTIFICATION DIVISION.
       PROGRAM-ID. RAPPORT-OCCUPATION.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════════════════╗"
           DISPLAY "║              RAPPORT D'OCCUPATION                              ║"
           DISPLAY "╚════════════════════════════════════════════════════════════════╝"
           
           STRING "echo '=== CHAMBRES OCCUPEES ===' && "
               "sqlite3 data/input/hotel.db 'SELECT NUMERO || \" - \" || STATUT "
               "FROM CHAMBRES WHERE STATUT != \"DISPONIBLE\";' && "
               "echo '' && "
               "echo '=== STATISTIQUES ===' && "
               "sqlite3 data/input/hotel.db 'SELECT \"Taux occupation: \" || "
               "ROUND(CAST((SELECT COUNT(*) FROM CHAMBRES WHERE STATUT != \"DISPONIBLE\") "
               "AS REAL) / (SELECT COUNT(*) FROM CHAMBRES) * 100, 2) || \"%\";'"
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           DISPLAY "╚════════════════════════════════════════════════════════════════╝"
           STOP RUN.
