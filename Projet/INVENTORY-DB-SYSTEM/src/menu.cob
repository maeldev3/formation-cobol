       IDENTIFICATION DIVISION.
       PROGRAM-ID. MENU.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-CHOICE PIC 9.
       PROCEDURE DIVISION.
           DISPLAY "=== MENU ==="
           DISPLAY "1. Ajouter categorie"
           ACCEPT WS-CHOICE
           IF WS-CHOICE = 1
               CALL "CREATE-CATEGORY"
           END-IF
           STOP RUN.