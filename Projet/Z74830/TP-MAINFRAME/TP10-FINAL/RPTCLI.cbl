       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTCLI.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.

       FILE-CONTROL.
           SELECT INFILE ASSIGN TO CLIENTS.

       DATA DIVISION.

       FILE SECTION.

       FD INFILE
           RECORD CONTAINS 80 CHARACTERS.

       01 INREC.
          05 CLI-ID      PIC X(3).
          05 FILLER      PIC X.
          05 CLI-NOM     PIC X(8).
          05 FILLER      PIC X(3).
          05 CLI-SAL     PIC 9(5).
          05 FILLER      PIC X(60).

       WORKING-STORAGE SECTION.

       01 EOF-FLAG       PIC X VALUE 'N'.

       01 WS-NB          PIC 9(3) VALUE ZERO.
       01 WS-TOTAL       PIC 9(7) VALUE ZERO.
       01 WS-MAX         PIC 9(5) VALUE ZERO.
       01 WS-MIN         PIC 9(5) VALUE 99999.
       01 WS-NB5000      PIC 9(3) VALUE ZERO.
       01 WS-MOY         PIC 9(7) VALUE ZERO.

       PROCEDURE DIVISION.

           OPEN INPUT INFILE

           PERFORM UNTIL EOF-FLAG = 'Y'

               READ INFILE
                   AT END
                       MOVE 'Y' TO EOF-FLAG

                   NOT AT END

                       DISPLAY "CLIENT : "
                               CLI-ID SPACE
                               CLI-NOM SPACE
                               CLI-SAL

                       ADD 1 TO WS-NB

                       ADD CLI-SAL TO WS-TOTAL

                       IF CLI-SAL > WS-MAX
                           MOVE CLI-SAL TO WS-MAX
                       END-IF

                       IF CLI-SAL < WS-MIN
                           MOVE CLI-SAL TO WS-MIN
                       END-IF

                       IF CLI-SAL >= 5000
                           ADD 1 TO WS-NB5000
                       END-IF

               END-READ

           END-PERFORM

           IF WS-NB > 0
               COMPUTE WS-MOY = WS-TOTAL / WS-NB
           END-IF

           DISPLAY " "
           DISPLAY "=============================="
           DISPLAY "      RAPPORT CLIENTS"
           DISPLAY "=============================="
           DISPLAY "NOMBRE CLIENTS    : " WS-NB
           DISPLAY "TOTAL SALAIRES    : " WS-TOTAL
           DISPLAY "SALAIRE MOYEN     : " WS-MOY
           DISPLAY "SALAIRE MAXIMUM   : " WS-MAX
           DISPLAY "SALAIRE MINIMUM   : " WS-MIN
           DISPLAY "SALAIRE >= 5000   : " WS-NB5000
           DISPLAY "=============================="

           CLOSE INFILE

           STOP RUN.
