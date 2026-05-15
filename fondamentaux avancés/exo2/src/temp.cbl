       IDENTIFICATION DIVISION.
       PROGRAM-ID. TEMP.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

           COPY "temp-const.cpy".
           COPY "temp-data.cpy".

       PROCEDURE DIVISION.

           PERFORM INITIALISATION

           PERFORM UNTIL ARRETER
               PERFORM AFFICHER-MENU
               PERFORM TRAITER-CHOIX
           END-PERFORM

           DISPLAY "MERCI ET A BIENTOT!"
           STOP RUN.

           COPY "temp-proc.cpy".