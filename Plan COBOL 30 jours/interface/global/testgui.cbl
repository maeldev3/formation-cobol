       IDENTIFICATION DIVISION.
       PROGRAM-ID. TESTGUI.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       01 WS-NOM    PIC X(30).
       01 WS-PAUSE  PIC X.

       SCREEN SECTION.

       01 ECRAN.
          05 BLANK SCREEN.
          05 LINE 2 COLUMN 20 VALUE "GESTION RH".
          05 LINE 5 COLUMN 10 VALUE "Nom :".
          05 LINE 5 COLUMN 20 PIC X(30) USING WS-NOM.

       01 ECRAN-RESULTAT.
          05 BLANK SCREEN.
          05 LINE 10 COLUMN 10 VALUE "Bonjour ".
          05 PIC X(30) FROM WS-NOM.
          05 LINE 15 COLUMN 10
             VALUE "Appuyez sur ENTREE pour quitter".

       PROCEDURE DIVISION.

           DISPLAY ECRAN
           ACCEPT ECRAN

           DISPLAY ECRAN-RESULTAT
           ACCEPT WS-PAUSE

           STOP RUN.