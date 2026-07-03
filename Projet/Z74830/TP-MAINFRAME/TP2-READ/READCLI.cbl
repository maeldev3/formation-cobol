       IDENTIFICATION DIVISION.
       PROGRAM-ID. READCLI.

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
       01 WS-EOF PIC X VALUE 'N'.

       PROCEDURE DIVISION.
           OPEN INPUT CLIENT-FILE

           PERFORM UNTIL WS-EOF = 'Y'
               READ CLIENT-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF
                   NOT AT END
                       DISPLAY "CLIENT : " CLI-ID
                       DISPLAY "NOM    : " CLI-NOM
                       DISPLAY "SALAIRE: " CLI-SAL
               END-READ
           END-PERFORM

           CLOSE CLIENT-FILE
           STOP RUN.
