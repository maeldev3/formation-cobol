       IDENTIFICATION DIVISION.
       PROGRAM-ID. WRITECLI.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CLIENT-FILE ASSIGN TO CLIENTS.

       DATA DIVISION.
       FILE SECTION.

       FD CLIENT-FILE
           RECORD CONTAINS 80 CHARACTERS.

       01 CLIENT-REC.
          05 CLI-ID      PIC X(3).
          05 FILLER      PIC X.
          05 CLI-NOM     PIC X(8).
          05 FILLER      PIC X(3).
          05 CLI-SAL     PIC 9(5).
          05 FILLER      PIC X(60).

       WORKING-STORAGE SECTION.
       01 WS-END PIC X VALUE 'N'.

       PROCEDURE DIVISION.

           OPEN EXTEND CLIENT-FILE

           MOVE SPACES TO CLIENT-REC


           DISPLAY "ENTRE ID (3): "
           ACCEPT CLI-ID

           DISPLAY "ENTRE NOM (8): "
           ACCEPT CLI-NOM

           DISPLAY "ENTRE SALAIRE (5): "
           ACCEPT CLI-SAL

           WRITE CLIENT-REC

           CLOSE CLIENT-FILE

           DISPLAY "CLIENT AJOUTE OK"

           STOP RUN.
