       IDENTIFICATION DIVISION.
       PROGRAM-ID. HELLOGUI.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-CHOIX PIC 9.
       01 WS-PAUSE PIC X.
       
       SCREEN SECTION.
       
       01 MAIN-SCREEN.
           05 BLANK SCREEN.
             05 LINE 2 COLUMN 20
           VALUE "MA PREMIERE FENETRE COBOL".
       05 LINE 5 COLUMN 10
           VALUE "Bonjour depuis GnuCOBOL".
       05 LINE 8 COLUMN 10
           VALUE "1 - Quitter".
       05 LINE 10 COLUMN 10
           VALUE "Choix : ".
             05 PIC 9 USING WS-CHOIX.
       
       PROCEDURE DIVISION.
       
       MAIN-PROGRAM.
       
           DISPLAY MAIN-SCREEN
           ACCEPT MAIN-SCREEN
       
           IF WS-CHOIX = 1
                DISPLAY "Au revoir !"
       ELSE
                DISPLAY "Choix invalide"
           END-IF
       
           DISPLAY "Appuyez sur ENTREE..."
           ACCEPT WS-PAUSE
       
           STOP RUN.