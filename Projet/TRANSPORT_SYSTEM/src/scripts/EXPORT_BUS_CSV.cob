       IDENTIFICATION DIVISION.
       PROGRAM-ID. EXPORT-BUS-CSV.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMMANDE      PIC X(200).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY "Export des bus vers CSV..."
           MOVE "sqlite3 -header -csv data/transport.db 'SELECT * FROM BUS;' "
               "> data/exports/bus_$(date +%Y%m%d).csv"
               TO WS-COMMANDE
           CALL "SYSTEM" USING WS-COMMANDE
           DISPLAY "✓ Export termine dans data/exports/"
           STOP RUN.
