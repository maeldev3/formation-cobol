       IDENTIFICATION DIVISION.
       PROGRAM-ID. STOCKAPP.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 I PIC 9.

       01 WS-PROD OCCURS 5 TIMES PIC X(10).
       01 WS-QTY  OCCURS 5 TIMES PIC 9(3).

       PROCEDURE DIVISION.

           MOVE "TV" TO WS-PROD(1)
           MOVE "PHONE" TO WS-PROD(2)
           MOVE "PC" TO WS-PROD(3)
           MOVE "MOUSE" TO WS-PROD(4)
           MOVE "KEYB" TO WS-PROD(5)

           MOVE 10 TO WS-QTY(1)
           MOVE 5 TO WS-QTY(2)
           MOVE 3 TO WS-QTY(3)
           MOVE 20 TO WS-QTY(4)
           MOVE 15 TO WS-QTY(5)

           PERFORM VARYING I FROM 1 BY 1 UNTIL I > 5
               DISPLAY "PROD : " WS-PROD(I)
               DISPLAY "QTY  : " WS-QTY(I)
           END-PERFORM

           STOP RUN.