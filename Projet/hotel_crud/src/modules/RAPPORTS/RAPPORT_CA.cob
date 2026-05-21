       IDENTIFICATION DIVISION.
       PROGRAM-ID. RAPPORT-CA.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║          RAPPORT CHIFFRE D'AFFAIRES                ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           
           STRING "echo '=== CA TOTAL ===' && "
               "sqlite3 data/input/hotel.db 'SELECT \"CA Global: \" || "
               "COALESCE(SUM(MONTANT), 0) || \" €\" FROM PAIEMENTS;' && "
               "echo '' && "
               "echo '=== CA PAR MOIS ===' && "
               "sqlite3 data/input/hotel.db 'SELECT strftime(\"%Y-%m\", DATE_PAIEMENT) "
               "|| \" | \" || SUM(MONTANT) || \"€\" FROM PAIEMENTS GROUP BY "
               "strftime(\"%Y-%m\", DATE_PAIEMENT);'"
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
