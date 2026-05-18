       IDENTIFICATION DIVISION.
       PROGRAM-ID. MENU1.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-CHOIX PIC 9.

       PROCEDURE DIVISION.

           DISPLAY "1. DEPOT"
           DISPLAY "2. RETRAIT"
           DISPLAY "3. QUITTER"

           ACCEPT WS-CHOIX

           EVALUATE WS-CHOIX
               WHEN 1
                   DISPLAY "DEPOT"

               WHEN 2
                   DISPLAY "RETRAIT"

               WHEN 3
                   DISPLAY "FIN"

               WHEN OTHER
                   DISPLAY "INVALIDE"
           END-EVALUATE

           STOP RUN.