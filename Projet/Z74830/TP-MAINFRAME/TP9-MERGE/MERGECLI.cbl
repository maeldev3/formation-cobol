       IDENTIFICATION DIVISION.
       PROGRAM-ID. MERGECLI.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.

       FILE-CONTROL.
           SELECT INFILE1 ASSIGN TO CLIENTS1.
           SELECT INFILE2 ASSIGN TO CLIENTS2.
           SELECT OUTFILE  ASSIGN TO CLNTSALL.

       DATA DIVISION.

       FILE SECTION.

       FD INFILE1
           RECORD CONTAINS 80 CHARACTERS.

0      1 INREC1.
         05 CLI-ID1   PIC X(3).
         05 FILLER    PIC X.
         05 CLI-NOM1  PIC X(8).
         05 FILLER    PIC X(3).
         05 CLI-SAL1  PIC 9(5).
         05 FILLER    PIC X(60).

       FD INFILE2
           RECORD CONTAINS 80 CHARACTERS.

       01 INREC2.
          05 CLI-ID2   PIC X(3).
          05 FILLER    PIC X.
          05 CLI-NOM2  PIC X(8).
          05 FILLER    PIC X(3).
          05 CLI-SAL2  PIC 9(5).
          05 FILLER    PIC X(60).

       FD OUTFILE
           RECORD CONTAINS 80 CHARACTERS.

       01 OUTREC.
          05 O-ID      PIC X(3).
          05 FILLER    PIC X.
          05 O-NOM     PIC X(8).
          05 FILLER    PIC X(3).
          05 O-SAL     PIC 9(5).
          05 FILLER    PIC X(60).


       WORKING-STORAGE SECTION.

       01 EOF1 PIC X VALUE 'N'.
       01 EOF2 PIC X VALUE 'N'.

       PROCEDURE DIVISION.

           OPEN INPUT INFILE1 INFILE2
                OUTPUT OUTFILE

           PERFORM READ1
           PERFORM READ2

           PERFORM UNTIL EOF1 = 'Y' AND EOF2 = 'Y'

               IF EOF1 = 'N'
                   MOVE INREC1 TO OUTREC
                   WRITE OUTREC
                   PERFORM READ1
               END-IF

               IF EOF2 = 'N'
                   MOVE INREC2 TO OUTREC
                   WRITE OUTREC
                   PERFORM READ2
               END-IF

           END-PERFORM

           CLOSE INFILE1 INFILE2 OUTFILE

           DISPLAY "MERGE TERMINE"

           STOP RUN.

       READ1.
           READ INFILE1
               AT END MOVE 'Y' TO EOF1
           END-READ.

       READ2.
           READ INFILE2
               AT END MOVE 'Y' TO EOF2
           END-READ.
