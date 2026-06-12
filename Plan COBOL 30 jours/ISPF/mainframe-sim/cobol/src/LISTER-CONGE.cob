       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-CONGE.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-NAME     PIC X(30).
       01 WS-DATE     PIC X(10).

       PROCEDURE DIVISION.

       MAIN-PARA.

           DISPLAY "============================"
           DISPLAY " LISTE DES CONGES"
           DISPLAY "============================"

           MOVE "RAKOTO ANNA" TO WS-NAME
           MOVE "2026-06-12" TO WS-DATE

           DISPLAY "EMPLOYE : " WS-NAME
           DISPLAY "DATE    : " WS-DATE

           STOP RUN.
