       IDENTIFICATION DIVISION.
       PROGRAM-ID. BATCH1.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-I        PIC 99 VALUE 1.
       01 WS-MONTANT  PIC 9(6)V99.
       01 WS-TOTAL    PIC 9(8)V99 VALUE ZERO.

       PROCEDURE DIVISION.

       000-MAIN.

           PERFORM UNTIL WS-I > 5

               DISPLAY "TRANSACTION " WS-I
               DISPLAY "MONTANT : "
               ACCEPT WS-MONTANT

               ADD WS-MONTANT TO WS-TOTAL
               ADD 1 TO WS-I

           END-PERFORM

           DISPLAY "TOTAL : " WS-TOTAL

           STOP RUN.