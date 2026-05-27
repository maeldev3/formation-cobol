       IDENTIFICATION DIVISION.
       PROGRAM-ID. BACKUP-DB.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMMANDE      PIC X(200).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY "Sauvegarde de la base de donnees..."
           MOVE "cp data/transport.db data/backup/transport_$(date +%Y%m%d_%H%M%S).db"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           DISPLAY "✓ Sauvegarde terminee dans data/backup/"
           STOP RUN.
