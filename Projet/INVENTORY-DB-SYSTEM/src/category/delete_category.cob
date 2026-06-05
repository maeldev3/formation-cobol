       IDENTIFICATION DIVISION.
       PROGRAM-ID. DELETE-CATEGORY.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-ID  PIC 9(5).
       01 WS-CMD PIC X(200).

       PROCEDURE DIVISION.

           DISPLAY "CATEGORY ID TO DELETE: "
           ACCEPT WS-ID

           STRING
              "sqlite3 db/inventory.db "
              "'DELETE FROM categories WHERE id_categorie=" WS-ID ";'"
              INTO WS-CMD
           END-STRING

           CALL "SYSTEM" USING WS-CMD

           DISPLAY "CATEGORY DELETED"

           STOP RUN.