       IDENTIFICATION DIVISION.
       PROGRAM-ID. LOGIN.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-USER PIC X(10).
       01 WS-PASS PIC X(10).

       PROCEDURE DIVISION.

           DISPLAY "LOGIN : "
           ACCEPT WS-USER

           DISPLAY "PASSWORD : "
           ACCEPT WS-PASS

           IF WS-USER = "admin" AND WS-PASS = "1234"
               DISPLAY "ACCESS GRANTED"
           ELSE
               DISPLAY "ACCESS DENIED"
           END-IF

           STOP RUN.