       IDENTIFICATION DIVISION.
       PROGRAM-ID. LOGOUT.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-COMMANDE     PIC X(100).

       PROCEDURE DIVISION.
           CALL "SYSTEM" USING "rm -f session.dat"
           DISPLAY " "
           DISPLAY "✓ Vous etes deconnecte. Merci !"
           STOP RUN.
