       IDENTIFICATION DIVISION.
       PROGRAM-ID. UPDATE-CATEGORY.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       01 WS-ID    PIC 9(5).
       01 WS-NAME  PIC X(50).
       01 WS-CMD   PIC X(300).

       PROCEDURE DIVISION.

           DISPLAY "CATEGORY ID: "
           ACCEPT WS-ID

           DISPLAY "NEW NAME: "
           ACCEPT WS-NAME

           STRING
              "sqlite3 db/inventory.db "
              "'UPDATE categories SET nom_categorie="
              "'" WS-NAME "' WHERE id_categorie=" WS-ID ";'"
              INTO WS-CMD
           END-STRING

           CALL "SYSTEM" USING WS-CMD

           DISPLAY "CATEGORY UPDATED"

           STOP RUN.