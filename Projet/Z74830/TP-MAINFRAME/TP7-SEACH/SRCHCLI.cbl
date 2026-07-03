       IDENTIFICATION DIVISION.
       PROGRAM-ID. SRCHCLI.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.

       FILE-CONTROL.

           SELECT INFILE
               ASSIGN TO CLIENTS.

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
       01 FOUND-FLAG     PIC X VALUE 'N'.

       PROCEDURE DIVISION.

           OPEN INPUT INFILE

           PERFORM UNTIL EOF-FLAG = 'Y'

               READ INFILE
                   AT END
                       MOVE 'Y' TO EOF-FLAG

                   NOT AT END

                       IF CLI-ID = "003"

                           DISPLAY "CLIENT TROUVE"

                           DISPLAY "ID       : " CLI-ID
                           DISPLAY "NOM      : " CLI-NOM
                           DISPLAY "SALAIRE  : " CLI-SAL

                           MOVE 'Y' TO FOUND-FLAG
                           MOVE 'Y' TO EOF-FLAG

                       END-IF

               END-READ

           END-PERFORM

           IF FOUND-FLAG = 'N'
               DISPLAY "CLIENT INTROUVABLE"
           END-IF

           CLOSE INFILE

           STOP RUN.
