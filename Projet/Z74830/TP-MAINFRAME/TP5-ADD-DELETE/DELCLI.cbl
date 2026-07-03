       IDENTIFICATION DIVISION.
       PROGRAM-ID. DELCLI.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.

       FILE-CONTROL.

           SELECT INFILE
               ASSIGN TO CLIENTS.

           SELECT OUTFILE
               ASSIGN TO OUTFILE.

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

       FD OUTFILE
           RECORD CONTAINS 80 CHARACTERS.

       01 OUTREC.
          05 O-ID        PIC X(3).
          05 FILLER      PIC X.
          05 O-NOM       PIC X(8).
          05 FILLER      PIC X(3).
          05 O-SAL       PIC 9(5).
          05 FILLER      PIC X(60).

       WORKING-STORAGE SECTION.

       01 EOF-FLAG       PIC X VALUE 'N'.

       PROCEDURE DIVISION.

           OPEN INPUT INFILE
                OUTPUT OUTFILE.

           PERFORM UNTIL EOF-FLAG = 'Y'

               READ INFILE
                   AT END
                       MOVE 'Y' TO EOF-FLAG

                   NOT AT END

                       IF CLI-ID NOT = "003"
                           MOVE INREC TO OUTREC
                           WRITE OUTREC
                       END-IF

               END-READ

           END-PERFORM.

           CLOSE INFILE
                 OUTFILE.

           DISPLAY "SUPPRESSION TERMINEE".

           STOP RUN.
