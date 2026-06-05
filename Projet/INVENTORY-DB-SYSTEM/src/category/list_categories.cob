       IDENTIFICATION DIVISION.
       PROGRAM-ID. LIST-CATEGORIES.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-CMD PIC X(200).

       PROCEDURE DIVISION.

           MOVE "sqlite3 db/inventory.db 'SELECT * FROM categories;'" TO WS-CMD

           CALL "SYSTEM" USING WS-CMD

           STOP RUN.