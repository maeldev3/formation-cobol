       IDENTIFICATION DIVISION.
       PROGRAM-ID. MENU.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 CHOIX PIC 9.

       PROCEDURE DIVISION.

           DISPLAY "===================="
           DISPLAY "GESTION COMMANDES"
           DISPLAY "===================="
           DISPLAY "1 - Clients"
           DISPLAY "2 - Articles"
           DISPLAY "3 - Commandes"
           DISPLAY "4 - Livraison"
           DISPLAY "0 - Quitter"

           ACCEPT CHOIX

           DISPLAY "Choix = " CHOIX

           STOP RUN.
