       IDENTIFICATION DIVISION.
       PROGRAM-ID. HELLOMENU.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-CHOIX PIC 9.

       PROCEDURE DIVISION.
       DEBUT.

           DISPLAY '=========================='.
           DISPLAY '      MENU HELLO MENU     '.
           DISPLAY '=========================='.
           DISPLAY '1 - HELLO WORLD'.
           DISPLAY '2 - QUITTER'.
           DISPLAY 'CHOIX : '.

           ACCEPT WS-CHOIX.

           EVALUATE WS-CHOIX
              WHEN 1
                 DISPLAY 'HELLO WORLD FROM HELLOMENU'
              WHEN 2
                 DISPLAY 'BYE BYE'
              WHEN OTHER
                 DISPLAY 'CHOIX INVALIDE'
           END-EVALUATE.

           STOP RUN.