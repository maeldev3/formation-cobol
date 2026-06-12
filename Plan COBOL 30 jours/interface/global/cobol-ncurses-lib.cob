       IDENTIFICATION DIVISION.
       PROGRAM-ID. MENU-RH.
       
       DATA DIVISION.
       
       WORKING-STORAGE SECTION.
       01 WS-NOM PIC X(30).
       
       SCREEN SECTION.
       
       01 ECRAN.
           05 BLANK SCREEN.
             05 LINE 2 COLUMN 20
           VALUE "SYSTEME RH COBOL".
       05 LINE 5 COLUMN 10
           VALUE "Nom : ".
       05 LINE 5 COLUMN 20
           PIC X(30) USING WS-NOM.
       
       PROCEDURE DIVISION.
       
           DISPLAY ECRAN
           ACCEPT ECRAN
       
           DISPLAY "Bonjour " WS-NOM
       
           STOP RUN.