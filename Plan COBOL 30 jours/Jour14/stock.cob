       IDENTIFICATION DIVISION.
       PROGRAM-ID. STOCKREP.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.

       FILE-CONTROL.
           SELECT STOCK-FILE
               ASSIGN TO "data/stock.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT REPORT-FILE
               ASSIGN TO "reports/stock_report.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD STOCK-FILE.
       01 STOCK-REC.
          05 ST-CODE     PIC 9(3).
          05 ST-NAME     PIC X(10).
          05 ST-QTY      PIC 9(4).
          05 ST-PRICE    PIC 9(7)V99.

       FD REPORT-FILE.
       01 REPORT-LINE.
          05 RL-CODE     PIC 9(3).
          05 FILLER      PIC X VALUE SPACE.
          05 RL-NAME     PIC X(10).
          05 FILLER      PIC X VALUE SPACE.
          05 RL-AMOUNT   PIC Z(8)9.99.

       WORKING-STORAGE SECTION.

       01 WS-EOF        PIC X VALUE "N".
       01 WS-AMOUNT     PIC 9(9)V99 VALUE 0.
       01 WS-TOTAL      PIC 9(10)V99 VALUE 0.

       PROCEDURE DIVISION.

       000-MAIN.

           MOVE 0 TO WS-TOTAL

           OPEN INPUT STOCK-FILE
           OPEN OUTPUT REPORT-FILE

           PERFORM UNTIL WS-EOF = "Y"

               READ STOCK-FILE
                   AT END
                       MOVE "Y" TO WS-EOF
                   NOT AT END
                       PERFORM 200-PROCESS
               END-READ

           END-PERFORM

           MOVE "TOTAL: " TO RL-NAME
           MOVE WS-TOTAL TO RL-AMOUNT
           MOVE 0 TO RL-CODE
           WRITE REPORT-LINE

           CLOSE STOCK-FILE
           CLOSE REPORT-FILE

           STOP RUN.