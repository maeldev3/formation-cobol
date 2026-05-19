       IDENTIFICATION DIVISION.
       PROGRAM-ID. UPDATESTK.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.

       FILE-CONTROL.

           SELECT IN-FILE
               ASSIGN TO "data/stock.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT OUT-FILE
               ASSIGN TO "data/stock_new.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD IN-FILE.
       01 IN-REC.
          05 IN-CODE     PIC 9(3).
          05 IN-NAME     PIC X(10).
          05 IN-QTY      PIC 9(4).

       FD OUT-FILE.
       01 OUT-REC.
          05 OUT-CODE    PIC 9(3).
          05 OUT-NAME    PIC X(10).
          05 OUT-QTY     PIC 9(4).

       WORKING-STORAGE SECTION.

       01 WS-EOF       PIC X VALUE "N".
       01 WS-ADD       PIC 9(4) VALUE 5.

       PROCEDURE DIVISION.

       000-MAIN.

           OPEN INPUT IN-FILE
           OPEN OUTPUT OUT-FILE

           PERFORM UNTIL WS-EOF = "Y"

               READ IN-FILE
                   AT END
                       MOVE "Y" TO WS-EOF
                   NOT AT END
                       PERFORM 200-PROCESS
               END-READ

           END-PERFORM

           CLOSE IN-FILE
           CLOSE OUT-FILE

           STOP RUN.

       200-PROCESS.

           IF IN-CODE = 002
               ADD WS-ADD TO IN-QTY
           END-IF

           MOVE IN-CODE TO OUT-CODE
           MOVE IN-NAME TO OUT-NAME
           MOVE IN-QTY  TO OUT-QTY

           WRITE OUT-REC.