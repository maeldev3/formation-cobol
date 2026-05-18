       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAYROLL.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-I PIC 99 VALUE 1.
       01 WS-SAL PIC 9(6)V99.
       01 WS-PRI PIC 9(5)V99.
       01 WS-TOT PIC 9(8)V99 VALUE ZERO.
       01 WS-EMP PIC 9(8)V99.

       PROCEDURE DIVISION.

           PERFORM UNTIL WS-I > 5

               DISPLAY "SALAIRE : "
               ACCEPT WS-SAL

               DISPLAY "PRIME : "
               ACCEPT WS-PRI

               COMPUTE WS-EMP = WS-SAL + WS-PRI

               ADD WS-EMP TO WS-TOT
               ADD 1 TO WS-I

           END-PERFORM

           DISPLAY "GLOBAL : " WS-TOT

           STOP RUN.