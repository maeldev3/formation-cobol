       IDENTIFICATION DIVISION.
       PROGRAM-ID. SALESRPT.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.

       FILE-CONTROL.

           SELECT SALES-FILE
               ASSIGN TO "data/sales.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT REPORT-FILE
               ASSIGN TO "reports/sales_report.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD SALES-FILE.
       01 SALES-REC.
          05 PRD-CODE     PIC 9(3).
          05 PRD-NAME     PIC X(10).
          05 PRD-QTY      PIC 9(3).
          05 PRD-PRICE    PIC 9(6).

       FD REPORT-FILE.
       01 REPORT-LINE     PIC X(80).

       WORKING-STORAGE SECTION.

       01 WS-EOF         PIC X VALUE "N".
       01 WS-TOTAL       PIC 9(9) VALUE 0.
       01 WS-AMOUNT      PIC 9(9) VALUE 0.

              PROCEDURE DIVISION.

       000-MAIN.

           OPEN INPUT SALES-FILE
           OPEN OUTPUT REPORT-FILE

           MOVE "=== SALES REPORT ===" TO REPORT-LINE
           WRITE REPORT-LINE

           PERFORM UNTIL WS-EOF = "Y"

               READ SALES-FILE
                   AT END
                       MOVE "Y" TO WS-EOF
                   NOT AT END
                       PERFORM 200-CALCULATE
               END-READ

           END-PERFORM

           MOVE WS-TOTAL TO REPORT-LINE
           WRITE REPORT-LINE

           CLOSE SALES-FILE
           CLOSE REPORT-FILE

           STOP RUN.
           
       200-CALCULATE.

           COMPUTE WS-AMOUNT = PRD-QTY * PRD-PRICE

           ADD WS-AMOUNT TO WS-TOTAL

           STRING
               "PRODUCT: " PRD-NAME
               " TOTAL: " WS-AMOUNT
               DELIMITED BY SIZE
               INTO REPORT-LINE
           END-STRING

           WRITE REPORT-LINE.           