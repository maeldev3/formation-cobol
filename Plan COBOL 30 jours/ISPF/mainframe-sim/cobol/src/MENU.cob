       IDENTIFICATION DIVISION.
       PROGRAM-ID. MENU.

       PROCEDURE DIVISION.

           CALL "init_screen"

           CALL "draw_menu"

           CALL "wait_key"

           CALL "close_screen"

           STOP RUN.