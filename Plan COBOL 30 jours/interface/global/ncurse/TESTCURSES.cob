       IDENTIFICATION DIVISION.
       PROGRAM-ID. TESTCURSES.

       PROCEDURE DIVISION.

           CALL "init_screen"

           CALL "print_title"

           CALL "wait_key"

           CALL "close_screen"

           STOP RUN.